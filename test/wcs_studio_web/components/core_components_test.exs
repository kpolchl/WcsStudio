defmodule WcsStudioWeb.CoreComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias WcsStudioWeb.CoreComponents, as: C

  describe "button/1" do
    test "renders its content and attributes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.button type="submit" class="custom">Save</C.button>
        """)

      assert html =~ "Save"
      assert html =~ ~s(type="submit")
      assert html =~ "custom"
    end
  end

  describe "label/1" do
    test "renders a label bound to a field" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.label for="field-id">My Label</C.label>
        """)

      assert html =~ ~s(for="field-id")
      assert html =~ "My Label"
    end
  end

  describe "error/1" do
    test "renders an error message" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.error>is invalid</C.error>
        """)

      assert html =~ "is invalid"
      assert html =~ "text-rose-600"
    end
  end

  describe "input/1" do
    test "renders a text input from a form field" do
      assigns = %{form: to_form(%{"email" => "a@b.com"}, as: :user)}

      html =
        rendered_to_string(~H"""
        <C.input field={@form[:email]} type="email" label="Email" />
        """)

      assert html =~ ~s(type="email")
      assert html =~ ~s(name="user[email]")
      assert html =~ ~s(value="a@b.com")
      assert html =~ "Email"
    end

    test "renders errors" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.input type="text" name="email" id="email" label="Email" errors={["is invalid"]} />
        """)

      assert html =~ "is invalid"
      assert html =~ "border-rose-400"
    end

    test "renders a plain input without a field" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.input type="text" name="raw" id="raw" value="value" label="Raw" />
        """)

      assert html =~ ~s(name="raw")
      assert html =~ ~s(value="value")
    end

    test "renders a select with options and prompt" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.input
          type="select"
          name="color"
          id="color"
          label="Color"
          prompt="Pick one"
          options={["Red", "Blue"]}
          value="Red"
        />
        """)

      assert html =~ "<select"
      assert html =~ "Pick one"
      assert html =~ "Red"
      assert html =~ "Blue"
    end

    test "renders a textarea" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.input type="textarea" name="body" id="body" value="hello" label="Body" />
        """)

      assert html =~ "<textarea"
      assert html =~ "hello"
    end

    test "renders a checkbox" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.input type="checkbox" name="active" id="active" value={true} label="Active" />
        """)

      assert html =~ ~s(type="checkbox")
      assert html =~ "checked"
    end
  end

  describe "header/1" do
    test "renders an inner block, subtitle and actions" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.header>
          Title
          <:subtitle>Subtitle</:subtitle>
          <:actions>Action</:actions>
        </C.header>
        """)

      assert html =~ "Title"
      assert html =~ "Subtitle"
      assert html =~ "Action"
    end
  end

  describe "simple_form/1" do
    test "renders a form with actions" do
      assigns = %{form: to_form(%{}, as: :item)}

      html =
        rendered_to_string(~H"""
        <C.simple_form for={@form}>
          fields
          <:actions>actions</:actions>
        </C.simple_form>
        """)

      assert html =~ "<form"
      assert html =~ "fields"
      assert html =~ "actions"
    end
  end

  describe "flash/1" do
    test "renders its inner block" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.flash kind={:info}>All good</C.flash>
        """)

      assert html =~ "All good"
      assert html =~ ~s(role="alert")
      assert html =~ "flash-info"
    end

    test "renders a message from the flash map" do
      assigns = %{flash: %{"error" => "Something broke"}}

      html =
        rendered_to_string(~H"""
        <C.flash kind={:error} flash={@flash} />
        """)

      assert html =~ "Something broke"
    end

    test "renders nothing when there is no message" do
      assigns = %{flash: %{}}

      html =
        rendered_to_string(~H"""
        <C.flash kind={:info} flash={@flash} />
        """)

      refute html =~ ~s(role="alert")
    end
  end

  describe "flash_group/1" do
    test "renders all flash containers" do
      assigns = %{flash: %{"info" => "welcome", "error" => "oops"}}

      html =
        rendered_to_string(~H"""
        <C.flash_group flash={@flash} />
        """)

      assert html =~ ~s(id="flash-group")
      assert html =~ "welcome"
      assert html =~ "Success!"
      assert html =~ "oops"
      assert html =~ "Error!"
      assert html =~ ~s(id="client-error")
      assert html =~ ~s(id="server-error")
    end
  end

  describe "modal/1" do
    test "renders title, subtitle and inner block" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.modal id="my-modal" show={true}>
          <:title>Modal Title</:title>
          <:subtitle>Modal Subtitle</:subtitle>
          Body
        </C.modal>
        """)

      assert html =~ ~s(id="my-modal")
      assert html =~ "Modal Title"
      assert html =~ "Modal Subtitle"
      assert html =~ "Body"
      assert html =~ ~s(id="my-modal-bg")
      assert html =~ ~s(aria-label="close")
    end
  end

  describe "confirm_modal/1" do
    test "renders defaults" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.confirm_modal
          id="confirm-1"
          title="Delete?"
          message="Are you sure?"
          confirm_event="delete_thing"
          confirm_value={42}
        />
        """)

      assert html =~ "Delete?"
      assert html =~ "Are you sure?"
      assert html =~ ~s(phx-click="delete_thing")
      assert html =~ ~s(phx-value-id="42")
      assert html =~ "Cancel"
      assert html =~ "Delete"
    end

    test "accepts custom button texts" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.confirm_modal
          id="confirm-2"
          title="Remove?"
          message="Sure?"
          confirm_event="remove"
          cancel_text="Nope"
          confirm_text="Yes please"
        />
        """)

      assert html =~ "Nope"
      assert html =~ "Yes please"
    end
  end

  describe "form_modal/1" do
    test "renders a form with default submit label" do
      assigns = %{form: to_form(%{}, as: :thing)}

      html =
        rendered_to_string(~H"""
        <C.form_modal id="fm" title="New Thing" form={@form} on_submit="save">
          <C.input type="text" name="thing[name]" id="thing_name" label="Name" />
        </C.form_modal>
        """)

      assert html =~ "New Thing"
      assert html =~ ~s(phx-submit="save")
      assert html =~ ~s(phx-change="validate")
      assert html =~ "Save"
      assert html =~ "Cancel"
      assert html =~ ~s(id="fm-content")
    end

    test "accepts a custom submit label and class" do
      assigns = %{form: to_form(%{}, as: :thing)}

      html =
        rendered_to_string(~H"""
        <C.form_modal
          id="fm2"
          title="Edit"
          form={@form}
          on_submit="update"
          submit_label="Update"
          submit_class="custom-class"
        >
          body
        </C.form_modal>
        """)

      assert html =~ "Update"
      assert html =~ "custom-class"
    end
  end

  describe "table/1" do
    test "renders columns, rows and actions" do
      assigns = %{id: "things", rows: [%{id: 1, name: "One"}, %{id: 2, name: "Two"}]}

      html =
        rendered_to_string(~H"""
        <C.table id={@id} rows={@rows}>
          <:col :let={row} label="ID">{row.id}</:col>
          <:col :let={row} label="Name">{row.name}</:col>
          <:action :let={row}>Edit {row.id}</:action>
        </C.table>
        """)

      assert html =~ "ID"
      assert html =~ "Name"
      assert html =~ "One"
      assert html =~ "Two"
      assert html =~ "Actions"
      assert html =~ ~s(id="things")
    end
  end

  describe "list/1" do
    test "renders items with titles" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.list>
          <:item title="First">1</:item>
          <:item title="Second">2</:item>
        </C.list>
        """)

      assert html =~ "First"
      assert html =~ "Second"
    end
  end

  describe "back/1" do
    test "renders a navigation link" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.back navigate="/posts">Back to posts</C.back>
        """)

      assert html =~ "Back to posts"
      assert html =~ ~s(href="/posts")
    end
  end

  describe "icon/1" do
    test "renders a heroicon span" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <C.icon name="hero-arrow-path" class="h-4 w-4" />
        """)

      assert html =~ "hero-arrow-path"
      assert html =~ "h-4 w-4"
    end
  end

  describe "pattern/1" do
    setup do
      pattern = %{
        id: 1,
        name: "Whip",
        dance_type: %{name_en: "West Coast Swing", name_pl: "WCS PL"},
        starting_hands: "left_left",
        ending_hands: "right_right",
        count_num: 6,
        video_url: "https://www.youtube.com/embed/abc",
        children: []
      }

      %{pattern: pattern}
    end

    test "renders the expanded pattern for an admin", %{pattern: pattern} do
      assigns = %{
        pattern: pattern,
        current_user: %{id: 2, role: "admin"},
        expanded_pattern_id: 1,
        status: "learned",
        locale: "en"
      }

      html =
        rendered_to_string(~H"""
        <C.pattern
          pattern={@pattern}
          current_user={@current_user}
          expanded_pattern_id={@expanded_pattern_id}
          status={@status}
          locale={@locale}
        />
        """)

      assert html =~ "West Coast Swing"
      assert html =~ "Whip"
      assert html =~ "left_left"
      assert html =~ "right_right"
      assert html =~ "Update"
      assert html =~ "Delete"
      assert html =~ "Learned"
      assert html =~ "https://www.youtube.com/embed/abc"
    end

    test "renders collapsed preview without a user", %{pattern: pattern} do
      assigns = %{
        pattern: pattern,
        current_user: nil,
        expanded_pattern_id: nil,
        locale: "en"
      }

      html =
        rendered_to_string(~H"""
        <C.pattern
          pattern={@pattern}
          current_user={@current_user}
          expanded_pattern_id={@expanded_pattern_id}
          locale={@locale}
        />
        """)

      assert html =~ "Click to expand pattern details"
      refute html =~ "Update"
    end

    test "renders the variation count and children", %{pattern: pattern} do
      child = %{
        id: 2,
        name: "Whip Variation",
        dance_type: pattern.dance_type,
        starting_hands: "left_left",
        ending_hands: "right_right",
        count_num: 6,
        video_url: nil,
        children: []
      }

      assigns = %{
        pattern: Map.put(pattern, :children, [child]),
        current_user: nil,
        expanded_pattern_id: nil,
        expanded_children_id: nil,
        expanded_children_ids: MapSet.new([1]),
        locale: "en"
      }

      html =
        rendered_to_string(~H"""
        <C.pattern
          pattern={@pattern}
          current_user={@current_user}
          expanded_pattern_id={@expanded_pattern_id}
          expanded_children_id={@expanded_children_id}
          expanded_children_ids={@expanded_children_ids}
          locale={@locale}
        />
        """)

      assert html =~ "Whip Variation"
      assert html =~ "variations"
    end
  end

  describe "lesson_box/1" do
    test "renders lesson details" do
      lesson = %{
        id: 10,
        title: "Whip Workshop",
        dance_type: %{name_en: "West Coast Swing"},
        level: %{name: "Beginner"},
        date: "2024-05-01",
        place: "Buma Square",
        instructors: [%{username: "Anna"}, %{username: "Bob"}],
        patterns: [%{name: "Whip"}],
        lesson_vid_url: "https://www.youtube.com/embed/xyz"
      }

      assigns = %{
        lesson: lesson,
        current_user: %{id: 2, role: "admin"},
        expanded_lesson_id: 10,
        attended: true,
        locale: "en"
      }

      html =
        rendered_to_string(~H"""
        <C.lesson_box
          lesson={@lesson}
          current_user={@current_user}
          expanded_lesson_id={@expanded_lesson_id}
          attended={@attended}
          locale={@locale}
        />
        """)

      assert html =~ "Whip Workshop"
      assert html =~ "Beginner"
      assert html =~ "Buma Square"
      assert html =~ "Anna"
      assert html =~ "Whip"
      assert html =~ "Update Lesson"
      assert html =~ "Attended"
    end

    test "renders the collapsed instructor count" do
      lesson = %{
        id: 11,
        title: "Solo",
        dance_type: %{name_en: "Solo"},
        level: %{name: "All"},
        date: "2024-01-01",
        place: "Home",
        instructors: [%{username: "Anna"}],
        patterns: [],
        lesson_vid_url: nil
      }

      assigns = %{lesson: lesson, current_user: nil, expanded_lesson_id: nil, locale: "en"}

      html =
        rendered_to_string(~H"""
        <C.lesson_box
          lesson={@lesson}
          current_user={@current_user}
          expanded_lesson_id={@expanded_lesson_id}
          locale={@locale}
        />
        """)

      assert html =~ "1 instructor"
      refute html =~ "Update Lesson"
    end
  end

  describe "post_highlight/1" do
    test "renders post summary and author" do
      assigns = %{
        post: %{
          id: 5,
          title: "My Post",
          body: "word word word",
          user: %{username: "bob", profile_pic_url: nil},
          inserted_at: ~N[2024-01-02 03:04:05]
        }
      }

      html =
        rendered_to_string(~H"""
        <C.post_highlight post={@post} />
        """)

      assert html =~ "My Post"
      assert html =~ "bob"
      assert html =~ "/blog/5"
      assert html =~ "Read more"
      assert html =~ "Jan 02, 2024"
    end
  end

  describe "translate_error/1 and translate_errors/2" do
    test "translates a simple error" do
      assert C.translate_error({"can't be blank", []}) == "can't be blank"
    end

    test "interpolates options" do
      msg = C.translate_error({"should be at least %{count} character(s)", [count: 12]})
      assert msg =~ "12"
    end

    test "translates errors for a field" do
      assert C.translate_errors([email: {"can't be blank", []}], :email) == ["can't be blank"]
    end

    test "returns an empty list for a field without errors" do
      assert C.translate_errors([], :email) == []
    end
  end

  describe "JS command helpers" do
    test "show/hide return JS structs" do
      assert %Phoenix.LiveView.JS{} = C.show("#foo")
      assert %Phoenix.LiveView.JS{} = C.hide("#foo")
    end

    test "show_modal/hide_modal return JS structs" do
      assert %Phoenix.LiveView.JS{} = C.show_modal("modal")
      assert %Phoenix.LiveView.JS{} = C.hide_modal("modal")
    end
  end
end
