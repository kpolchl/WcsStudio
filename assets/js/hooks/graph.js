import cytoscape from "cytoscape";

// Fallback palette. The LiveView passes the real one through `data-colors`
// (single source of truth), so the legend and the graph can never drift apart.
const DEFAULT_COLORS = {
  starting_position: "#cbd5e1",
  left_left: "#f87171",
  left_right: "#facc15",
  right_right: "#22d3ee",
  right_left: "#4ade80",
  both_hands: "#e879f9",
};
const FALLBACK_COLOR = "#64748b";
const NODE_BG = "#0f172a";

// Set to true to drag nodes around; new logical coordinates are logged to the
// console so they can be pasted into BASE_POSITIONS below.
const TUNING = false;

// Responsive preset positions — scaled at render time to fill the container.
// Base coordinates on a 1200×500 logical canvas; layout() scales them.
const BASE_POSITIONS = {
  left_left: { x: 93, y: 175 },
  left_right: { x: 324, y: 492 },
  right_right: { x: 525, y: 84 }, // nudged down so its self-loop isn't clipped
  right_left: { x: 1047, y: 338 },
  both_hands: { x: 1011, y: 182 },
  starting_position: { x: 67, y: 273 },
};

// Space kept free around the layout (px) so outward loops aren't clipped
const PAD = 80;
const PAD_MOBILE = 36;

// Self-loops: a narrow sweep + tall reach gives a sharp teardrop instead of a
// flat arch. REACH = how far (px) the loop's control points sit beyond the
// node box; SWEEP = angle (deg) between the loop's two legs.
const LOOP_SWEEP = 34;
const LOOP_SWEEP_MOBILE = 40;
const LOOP_REACH = 64;
const LOOP_REACH_MOBILE = 36;
// Keep this many px between a loop's apex and the canvas edge (room for its
// label while a pattern is being played)
const LOOP_EDGE_MARGIN = 28;

// Distance from a rectangle's centre to its border along `deg`
// (0° = up, clockwise), for half-size hw × hh.
const boxRadius = (hw, hh, deg) => {
  const t = (deg * Math.PI) / 180;
  const dx = Math.abs(Math.sin(t));
  const dy = Math.abs(Math.cos(t));
  return Math.min(
    dx > 1e-6 ? hw / dx : Infinity,
    dy > 1e-6 ? hh / dy : Infinity,
  );
};

const BASE_W = 1200;
const BASE_H = 500;

// Mobile: vertical / stacked layout (narrower screens)
const BASE_POSITIONS_MOBILE = {
  starting_position: { x: 180, y: 55 },
  left_left: { x: 95, y: 185 },
  left_right: { x: 265, y: 185 },
  right_right: { x: 95, y: 350 },
  right_left: { x: 265, y: 350 },
  both_hands: { x: 180, y: 510 },
};
const BASE_W_MOBILE = 360;
const BASE_H_MOBILE = 580;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

/*
 * How the graph is presented
 * ──────────────────────────
 * Every pattern is an edge (class "detail"), but showing all of them at once
 * is an unreadable hairball. So the default "overview" shows ONE summary edge
 * (class "bundle") per source→target pair, with a count badge. Then:
 *
 *   tap a node    → hide bundles, show that node's individual patterns
 *   tap a badge   → show only the patterns for that one transition
 *   tap a pattern → push "pattern_selected" to the LiveView (details panel)
 *   Practice      → hide bundles, reveal the flow one pattern at a time
 *   tap background→ back to the overview
 */
const PatternGraph = {
  mounted() {
    const { nodes, edges } = JSON.parse(this.el.dataset.graph);
    const colors = {
      ...DEFAULT_COLORS,
      ...JSON.parse(this.el.dataset.colors || "{}"),
    };
    const colorOf = (id) => colors[id] || FALLBACK_COLOR;

    this.runId = 0;
    this.view = "overview"; // overview | node | pair | practice
    this._selectedNode = null;
    this.maxCount = 1;
    this.isMobile = () => this.el.clientWidth < 640;
    const m = (desktop, mobile) => (this.isMobile() ? mobile : desktop);

    this.cy = cytoscape({
      container: this.el,
      elements: [...nodes, ...edges],
      autoungrabify: !TUNING,
      userZoomingEnabled: false,
      userPanningEnabled: false,
      boxSelectionEnabled: false,
      style: [
        // ── Nodes: dark pill, coloured border + soft glow ──────────
        {
          selector: "node",
          style: {
            shape: "round-rectangle",
            width: "label",
            height: "label",
            padding: () => m("16px", "8px"),
            label: (n) => n.data("label"),
            color: NODE_BG, // dark text on solid, saturated fills
            "font-size": () => m(18, 12),
            "font-weight": 700,
            "text-valign": "center",
            "text-halign": "center",
            "background-color": (n) => colorOf(n.id()),
            "background-opacity": 1,
            "border-width": () => m(2, 1.5),
            "border-color": "#ffffff",
            "border-opacity": 0.35,
            "shadow-blur": () => m(18, 8),
            "shadow-color": (n) => colorOf(n.id()),
            "shadow-opacity": 0.5,
            "shadow-offset-x": 0,
            "shadow-offset-y": 0,
            cursor: "pointer",
            "transition-property":
              "border-color, border-width, border-opacity, shadow-opacity, shadow-blur, background-opacity, opacity",
            "transition-duration": "250ms",
          },
        },

        // ── Edges (base) ───────────────────────────────────────────
        {
          selector: "edge",
          style: {
            "curve-style": "unbundled-bezier",
            "control-point-weights": 0.5,
            // Offset is computed per edge in assignEdgeSlots()
            "control-point-distances": (e) => e.data("_cpDist") || 0,
            // Cytoscape forces self-loops to curve-style "bezier", which
            // ignores control-point-distances: a loop's size comes from the
            // step size instead (sized per node in layout()).
            "control-point-step-size": (e) =>
              e.isLoop() ? e.source().data("_loopDist") || m(80, 40) : 40,
            "source-endpoint": "outside-to-line",
            "target-endpoint": "outside-to-line",
            "source-distance-from-node": 2,
            "target-distance-from-node": 3,
            width: (e) => this.edgeWidth(e.data("weight")),
            "line-color": (e) => colorOf(e.data("source")),
            "target-arrow-color": (e) => colorOf(e.data("source")),
            "target-arrow-shape": "triangle",
            "arrow-scale": () => m(1.1, 0.8),
            opacity: 0.9, // keep high: translucent lines blend into the purple background
            cursor: "pointer",
            // Self-loops point away from the middle of the graph; the angle
            // (clockwise from 12 o'clock) is computed per node in layout().
            "loop-direction": (e) => `${e.source().data("_loopDeg") || 0}deg`,
            "loop-sweep": () => `${m(LOOP_SWEEP, LOOP_SWEEP_MOBILE)}deg`,
            "transition-property": "opacity, line-color, width",
            "transition-duration": "250ms",
          },
        },

        // Individual pattern edges are hidden unless explicitly revealed
        { selector: "edge.detail", style: { display: "none" } },
        { selector: "edge.detail.show", style: { display: "element" } },

        // ── Labelled / highlighted edges ───────────────────────────
        {
          selector: "edge.labeled",
          style: {
            label: (e) =>
              e.data("weight")
                ? `${e.data("label")} · ${e.data("weight")}`
                : e.data("label"),
            "z-index": 10,
            opacity: 1,
            "font-size": () => m(13, 10),
            color: "#f8fafc",
            "text-background-color": NODE_BG,
            "text-background-opacity": 0.92,
            "text-background-padding": () => m("4px", "2px"),
            "text-background-shape": "roundrectangle",
            "text-border-width": 1,
            "text-border-color": (e) => colorOf(e.data("source")),
            "text-border-opacity": 0.6,
            // Rotation keeps labels from colliding on parallel edges
            "text-rotation": "autorotate",
            "text-margin-y": () => m(-8, -6),
          },
        },
        // The single edge being hovered / selected — white highlight
        {
          selector: "edge.hover, edge:selected",
          style: {
            label: (e) =>
              e.data("weight")
                ? `${e.data("label")} · ${e.data("weight")}`
                : e.data("label"),
            "z-index": 15,
            opacity: 1,
            "font-size": () => m(13, 10),
            color: "#f8fafc",
            "text-background-color": NODE_BG,
            "text-background-opacity": 0.92,
            "text-background-padding": () => m("4px", "2px"),
            "text-background-shape": "roundrectangle",
            "text-border-width": 1,
            "text-border-color": "#ffffff",
            "text-border-opacity": 0.6,
            "text-rotation": "autorotate",
            "text-margin-y": () => m(-8, -6),
            "line-color": "#ffffff",
            "target-arrow-color": "#ffffff",
          },
        },

        // ── Dimmed elements (when something is focused) ────────────
        { selector: ".dim", style: { opacity: 0.06 } },

        // ── Focused node: brighter, bigger glow ────────────────────
        {
          selector: "node.focused",
          style: {
            "border-color": "#ffffff",
            "border-width": 3,
            "border-opacity": 1,
            "shadow-opacity": 0.85,
            "shadow-blur": 30,
          },
        },

        // ── Practice flow animation ────────────────────────────────
        {
          selector: "edge.flow, edge.done",
          style: {
            label: (e) => {
              const step = e.data("_practiceStep");
              const prefix = step ? `${step}. ` : "";
              return e.data("weight")
                ? `${prefix}${e.data("label")} · ${e.data("weight")}`
                : `${prefix}${e.data("label")}`;
            },
            opacity: 1,
            "font-size": () => m(12, 10),
            color: "#f8fafc",
            "text-background-color": NODE_BG,
            "text-background-opacity": 0.92,
            "text-background-padding": () => m("3px", "2px"),
            "text-background-shape": "roundrectangle",
            "text-rotation": "autorotate",
            "text-margin-y": () => m(-8, -6),
          },
        },
        {
          selector: "edge.flow",
          style: {
            "z-index": 20,
            width: () => m(5, 3),
            "line-style": "dashed",
            "line-dash-pattern": [10, 6],
            // The step being played is white; finished steps keep their own colour
            "line-color": "#ffffff",
            "target-arrow-color": "#ffffff",
            "text-border-width": 1,
            "text-border-color": "#ffffff",
            "text-border-opacity": 0.8,
          },
        },
        {
          selector: "edge.done",
          style: {
            "z-index": 18,
            opacity: 1,
            "line-style": "solid",
            width: () => m(4.5, 2.5),
            "text-border-width": 1,
            "text-border-color": (e) => colorOf(e.data("source")),
            "text-border-opacity": 0.9,
          },
        },
        {
          selector: "node.current",
          style: {
            "border-color": "#ffffff",
            "border-width": 4,
            "border-opacity": 1,
            "shadow-opacity": 0.9,
          },
        },

        // ── Self-loops: horizontal labels (autorotate looks wrong on a loop)
        {
          selector: "edge.loop",
          style: { "text-rotation": "none", "text-margin-y": () => m(-10, -8) },
        },

        // ── Bundles: one summary edge per source→target pair ───────
        {
          selector: "edge.bundle",
          style: {
            width: (e) => this.bundleWidth(e.data("count")),
            opacity: 0.95,
            "z-index": 5,
            label: (e) => e.data("label"),
            "font-size": () => m(13, 10),
            "font-weight": 700,
            // Solid badge in the arrow's colour, dark number on top
            color: NODE_BG,
            "text-background-color": (e) => colorOf(e.data("source")),
            "text-background-opacity": 1,
            "text-background-padding": () => m("4px", "3px"),
            "text-background-shape": "roundrectangle",
            "text-border-width": 1.5,
            "text-border-color": NODE_BG,
            "text-border-opacity": 0.9,
            "text-rotation": "none",
            "text-margin-y": 0,
          },
        },
        {
          selector: "edge.bundle.hl, edge.bundle.hover",
          style: { opacity: 1, "z-index": 12 },
        },
        { selector: "edge.bundle.hidden", style: { display: "none" } },
      ],
    });

    this.rebuild();
    // Node boxes are only measured once the canvas has painted: lay out again
    // so loop sizes use real dimensions rather than estimates.
    this.cy.one("render", () => this.layout());

    // ── Interactions ────────────────────────────────────────────────

    if (TUNING) {
      this.cy.on("dragfree", "node", () => this.logTunedPositions());
    }

    // Hover an edge: highlight it (and reveal its label)
    this.cy.on("mouseover", "edge", (e) => e.target.addClass("hover"));
    this.cy.on("mouseout", "edge", (e) => e.target.removeClass("hover"));

    // Hover a node in the overview: light up the arrows touching it
    this.cy.on("mouseover", "node", (e) => {
      if (this.view !== "overview") return;
      e.target.connectedEdges(".bundle").addClass("hl");
    });
    this.cy.on("mouseout", "node", (e) => {
      e.target.connectedEdges(".bundle").removeClass("hl");
    });

    // Edge tap: a bundle expands into its patterns; a pattern is selected
    this.cy.on("tap", "edge", (e) => {
      const edge = e.target;
      if (edge.hasClass("bundle")) return this.focusPair(edge);
      this.pushEvent("pattern_selected", { id: edge.data("pattern_id") });
    });

    // Node tap: focus it — tapping the same node again goes back to overview
    this.cy.on("tap", "node", (e) => {
      const node = e.target;
      const same = this.view === "node" && this._selectedNode === node.id();
      this.showOverview();
      if (!same) this.focusNode(node);
    });

    // Background tap: back to overview
    this.cy.on("tap", (e) => {
      if (e.target === this.cy) this.showOverview();
    });

    // ── Server events ──────────────────────────────────────────────
    this.handleEvent("graph:practice", ({ steps }) => this.playPractice(steps));
    this.handleEvent("graph:reset", () => this.stopPractice());

    this.handleEvent("graph:update", ({ nodes, edges }) => {
      this.stopPractice();
      this.cy.elements().remove();
      this.cy.add([...nodes, ...edges]);
      this.rebuild();
    });

    // ── Resize observer ────────────────────────────────────────────
    this.ro = new ResizeObserver(() => {
      this.cy.resize();
      this.layout();
    });
    this.ro.observe(this.el);
  },

  // ── (Re)build derived state after elements change ──────────────────
  rebuild() {
    this.buildBundles();
    this.updateWeightRange();
    this.showOverview();
    this.layout();
  },

  // Tag every pattern edge as "detail" and add one "bundle" edge per
  // source→target pair carrying the number of patterns in it.
  buildBundles() {
    const cy = this.cy;
    cy.remove("edge.bundle");

    const groups = new Map();
    cy.edges().forEach((e) => {
      const source = e.data("source");
      const target = e.data("target");
      e.addClass("detail");
      if (source === target) e.addClass("loop");

      const key = `${source}>${target}`;
      if (!groups.has(key)) groups.set(key, { source, target, count: 0 });
      groups.get(key).count += 1;
    });

    const bundles = [...groups.values()];
    this.maxCount = Math.max(1, ...bundles.map((g) => g.count));

    cy.add(
      bundles.map((g) => ({
        group: "edges",
        data: {
          id: `bundle:${g.source}>${g.target}`,
          source: g.source,
          target: g.target,
          count: g.count,
          label: String(g.count),
        },
        classes: g.source === g.target ? "bundle loop" : "bundle",
      })),
    );
  },

  // ── Views ──────────────────────────────────────────────────────────

  // Reset everything (also cancels a running practice animation).
  showOverview() {
    this.runId += 1;
    cancelAnimationFrame(this.raf);
    this.view = "overview";
    this._selectedNode = null;

    const cy = this.cy;
    cy.edges().removeData("_practiceStep");
    cy.edges().removeStyle("line-dash-offset");
    cy.elements()
      .unselect()
      .removeClass(
        "dim labeled flow done current hover focused hl show hidden",
      );
  },

  stopPractice() {
    this.showOverview();
  },

  focusNode(node) {
    const cy = this.cy;
    this.view = "node";
    this._selectedNode = node.id();

    cy.edges(".bundle").addClass("hidden");
    cy.elements().addClass("dim");

    const patterns = node.connectedEdges().not(".bundle");
    patterns.addClass("show labeled").removeClass("dim");
    patterns.connectedNodes().removeClass("dim");
    node.addClass("focused");
  },

  focusPair(bundle) {
    const cy = this.cy;
    const source = bundle.data("source");
    const target = bundle.data("target");
    this.showOverview();
    this.view = "pair";

    cy.edges(".bundle").addClass("hidden");
    cy.elements().addClass("dim");

    const patterns = cy
      .edges(".detail")
      .filter(
        (e) => e.data("source") === source && e.data("target") === target,
      );
    patterns.addClass("show labeled").removeClass("dim");
    patterns.connectedNodes().removeClass("dim");
  },

  // ── DEV HELPER: Tune Layout Positions (needs TUNING = true) ─────────
  logTunedPositions() {
    const cw = this.el.clientWidth;
    const ch = this.el.clientHeight;
    const isMobile = cw < 640;

    const bw = isMobile ? BASE_W_MOBILE : BASE_W;
    const bh = isMobile ? BASE_H_MOBILE : BASE_H;
    const pad = isMobile ? PAD_MOBILE : PAD;

    const scale = Math.min((cw - pad * 2) / bw, (ch - pad * 2) / bh);
    const offsetX = (cw - bw * scale) / 2;
    const offsetY = (ch - bh * scale) / 2;

    const result = {};
    this.cy.nodes().forEach((node) => {
      const pos = node.position();
      result[node.id()] = {
        x: Math.round((pos.x - offsetX) / scale),
        y: Math.round((pos.y - offsetY) / scale),
      };
    });

    const mode = isMobile ? "BASE_POSITIONS_MOBILE" : "BASE_POSITIONS";
    console.log(
      `%c--- Copy this into ${mode} ---`,
      "color: #22d3ee; font-weight: bold; font-size: 14px;",
    );
    const entries = Object.entries(result).map(([id, pos]) => {
      const padId = `"${id}":`.padEnd(22);
      return `  ${padId} { x: ${pos.x}, y: ${pos.y} },`;
    });
    console.log(`const ${mode} = {\n${entries.join("\n")}\n};`);
  },

  // ── Fan parallel edges apart ───────────────────────────────────────
  // Edges between the same two nodes (in either direction) share a group and
  // are spread symmetrically around the straight line. The offset is computed
  // in a canonical frame (lower id → higher id) and flipped for edges going
  // the other way, because Cytoscape measures the distance relative to each
  // edge's own direction. Bundles and patterns are grouped separately.
  assignEdgeSlots() {
    const isMobile = this.isMobile();
    const groups = {};

    this.cy.edges().forEach((e) => {
      const kind = e.hasClass("bundle") ? "b" : "d";
      const pair = [e.data("source"), e.data("target")].sort();
      const key = `${kind}|${pair.join("|")}`;
      (groups[key] = groups[key] || []).push(e);
    });

    Object.entries(groups).forEach(([key, group]) => {
      const isBundle = key.startsWith("b|");
      const n = group.length;

      // Self-loops are sized via control-point-step-size (see the style); the
      // renderer stacks several loops on one node by itself.
      if (group[0].data("source") === group[0].data("target")) return;

      if (n === 1) {
        // Slight curve, so a lone edge looks intentional
        group[0].data("_cpDist", isMobile ? 12 : 20);
        return;
      }

      const spacing = isBundle ? (isMobile ? 26 : 44) : isMobile ? 24 : 50;
      group.forEach((e, i) => {
        const canonical = e.data("source") <= e.data("target") ? 1 : -1;
        e.data("_cpDist", (i - (n - 1) / 2) * spacing * canonical);
      });
    });
  },

  // ── Practice flow animation ────────────────────────────────────────
  async playPractice(steps) {
    this.showOverview();
    this.view = "practice";
    const run = this.runId;

    this.cy.edges(".bundle").addClass("hidden");
    this.cy.elements().addClass("dim");

    let prev = null;
    for (let i = 0; i < steps.length; i++) {
      if (run !== this.runId) return;

      const step = steps[i];
      const edge = this.cy.getElementById(step.edge_id);
      if (edge.empty()) continue;

      if (prev) {
        prev.removeClass("flow").addClass("done");
        prev.removeStyle("line-dash-offset");
      }
      this.cy.nodes(".current").removeClass("current");

      edge.data("_practiceStep", i + 1);
      edge.removeClass("dim").addClass("show flow");
      edge.connectedNodes().removeClass("dim");
      edge.target().addClass("current");
      this.animateDash(edge, run);

      await sleep(Math.max(900, step.count * 120));
      prev = edge;
    }

    if (run !== this.runId) return;
    if (prev) {
      prev.removeClass("flow").addClass("done");
      prev.removeStyle("line-dash-offset");
    }
  },

  animateDash(edge, run) {
    let offset = 0;
    const tick = () => {
      if (run !== this.runId || !edge.hasClass("flow")) return;
      offset = (offset + 0.7) % 16;
      edge.style("line-dash-offset", -offset);
      this.raf = requestAnimationFrame(tick);
    };
    cancelAnimationFrame(this.raf);
    tick();
  },

  // ── Layout / sizing ────────────────────────────────────────────────
  updateWeightRange() {
    const w = this.cy
      .edges()
      .filter((e) => !e.hasClass("bundle"))
      .map((e) => e.data("weight"));
    this.minW = w.length ? Math.min(...w) : 0;
    this.maxW = w.length ? Math.max(...w) : 0;
    this.cy.style().update();
  },

  // Pattern edges: only a gentle difference between short and long patterns
  edgeWidth(weight) {
    const mobile = this.isMobile ? this.isMobile() : false;
    const t =
      this.maxW === this.minW
        ? 0.5
        : (weight - this.minW) / (this.maxW - this.minW);
    return mobile ? 1.6 + 1.4 * t : 3 + 2 * t;
  },

  // Bundles: width grows with the number of patterns (sqrt keeps big ones sane)
  bundleWidth(count) {
    const mobile = this.isMobile ? this.isMobile() : false;
    const t = Math.sqrt((count || 1) / (this.maxCount || 1));
    return mobile ? 1.5 + 2.5 * t : 2.5 + 5 * t;
  },

  loopSweep() {
    return this.isMobile() ? LOOP_SWEEP_MOBILE : LOOP_SWEEP;
  },

  // Half width/height of a node's box. Falls back to an estimate if Cytoscape
  // hasn't measured the label yet (the first layout happens before first paint;
  // a second layout is triggered right after the first render).
  nodeHalfSize(n) {
    const bb = n.boundingBox({
      includeLabels: false,
      includeOverlays: false,
      includeEdges: false,
    });
    let w = bb.w;
    let h = bb.h;
    if (!(w > 20 && h > 10)) {
      const mobile = this.isMobile();
      const fs = mobile ? 12 : 18;
      const pad = mobile ? 8 : 16;
      w = String(n.data("label") || "").length * fs * 0.62 + pad * 2;
      h = fs * 1.3 + pad * 2;
    }
    return { hw: w / 2, hh: h / 2 };
  },

  layout() {
    const cw = this.el.clientWidth;
    const ch = this.el.clientHeight;
    const isMobile = this.isMobile();

    const positions = isMobile ? BASE_POSITIONS_MOBILE : BASE_POSITIONS;
    const bw = isMobile ? BASE_W_MOBILE : BASE_W;
    const bh = isMobile ? BASE_H_MOBILE : BASE_H;

    // Scale to fill the container. Padding leaves room for outward self-loops.
    const pad = isMobile ? PAD_MOBILE : PAD;
    const scale = Math.min((cw - pad * 2) / bw, (ch - pad * 2) / bh);
    const offsetX = (cw - bw * scale) / 2;
    const offsetY = (ch - bh * scale) / 2;

    const placed = {};
    this.cy.nodes().forEach((n) => {
      const base = positions[n.id()] || { x: 0, y: 0 };
      placed[n.id()] = {
        x: base.x * scale + offsetX,
        y: base.y * scale + offsetY,
      };
    });

    // Point each node's self-loops away from the centroid of all nodes.
    // Cytoscape angles: 0° = up, clockwise positive.
    const pts = Object.values(placed);
    const mx = pts.reduce((s, p) => s + p.x, 0) / (pts.length || 1);
    const my = pts.reduce((s, p) => s + p.y, 0) / (pts.length || 1);
    this.cy.nodes().forEach((n) => {
      const dx = placed[n.id()].x - mx;
      const dy = placed[n.id()].y - my;
      const deg =
        Math.hypot(dx, dy) < 1 ? 0 : (Math.atan2(dx, -dy) * 180) / Math.PI;
      n.data("_loopDeg", Math.round(deg));

      // Loop size. Cytoscape puts the two loop control points at 1.4 × the
      // control-point distance, at ±sweep/2 around the loop direction. They
      // MUST lie outside the node box, otherwise the edge is flagged
      // "bad" and silently not drawn (wide nodes pointing sideways/down did
      // exactly that). So size each loop from the node's real box, plus a
      // fixed reach beyond it that sets how tall/sharp the loop looks.
      const { hw, hh } = this.nodeHalfSize(n);
      const half = this.loopSweep() / 2;
      const clear = Math.max(
        boxRadius(hw, hh, deg - half),
        boxRadius(hw, hh, deg + half),
      );
      let R = clear + (isMobile ? LOOP_REACH_MOBILE : LOOP_REACH);

      // Never let a loop run off the canvas: cap R by the room left in the
      // loop's direction (the apex sits at ≈ R·cos(half-sweep)), but keep it
      // large enough to clear the node box.
      const rad = (deg * Math.PI) / 180;
      const ux = Math.sin(rad);
      const uy = -Math.cos(rad);
      const p = placed[n.id()];
      const edge = LOOP_EDGE_MARGIN;
      const room = Math.min(
        ux > 1e-6
          ? (cw - edge - p.x) / ux
          : ux < -1e-6
            ? (edge - p.x) / ux
            : Infinity,
        uy > 1e-6
          ? (ch - edge - p.y) / uy
          : uy < -1e-6
            ? (edge - p.y) / uy
            : Infinity,
      );
      R = Math.max(
        clear + 14,
        Math.min(R, room / Math.cos((half * Math.PI) / 180)),
      );

      n.data("_loopDist", R / 1.4);
    });

    // Needs the loop sizes above
    this.assignEdgeSlots();

    this.cy
      .layout({
        name: "preset",
        positions: (n) => placed[n.id()],
        fit: false, // We handle sizing ourselves
        padding: 0,
      })
      .run();

    this.cy.zoom(1);
    this.cy.pan({ x: 0, y: 0 });
    this.cy.style().update();
  },

  destroyed() {
    cancelAnimationFrame(this.raf);
    this.runId += 1;
    this.ro && this.ro.disconnect();
    this.cy && this.cy.destroy();
  },
};

export default PatternGraph;
