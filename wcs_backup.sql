--
-- PostgreSQL database dump
--

\restrict U1R42op2CpsxBAp2vkypvvScywsZiUf2ZIDcnL8f897XimrglzAdQJ2IVYYC7Mw

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    body text NOT NULL,
    user_id bigint NOT NULL,
    post_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: dance_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dance_types (
    id bigint NOT NULL,
    name_pl character varying(255) NOT NULL,
    description_pl text,
    country_pl character varying(255),
    tag_pl character varying(255),
    name_en character varying(255) NOT NULL,
    description_en text,
    country_en character varying(255),
    tag_en character varying(255),
    type character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    pic_url character varying(50)
);


--
-- Name: dance_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dance_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dance_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dance_types_id_seq OWNED BY public.dance_types.id;


--
-- Name: lesson_patterns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson_patterns (
    id bigint NOT NULL,
    lesson_id bigint NOT NULL,
    pattern_id bigint NOT NULL
);


--
-- Name: lesson_patterns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lesson_patterns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lesson_patterns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lesson_patterns_id_seq OWNED BY public.lesson_patterns.id;


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lessons (
    id bigint NOT NULL,
    dance_type_id bigint NOT NULL,
    title character varying(255) NOT NULL,
    place character varying(255),
    level_id bigint NOT NULL,
    lesson_vid_url character varying(255),
    date date NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lessons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lessons_id_seq OWNED BY public.lessons.id;


--
-- Name: lessons_instructors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lessons_instructors (
    id bigint NOT NULL,
    lesson_id bigint NOT NULL,
    instructor_id bigint NOT NULL
);


--
-- Name: lessons_instructors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lessons_instructors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lessons_instructors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lessons_instructors_id_seq OWNED BY public.lessons_instructors.id;


--
-- Name: levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.levels (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.levels_id_seq OWNED BY public.levels.id;


--
-- Name: patterns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patterns (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    leader_description_en text,
    follower_description_en text,
    leader_description_pl text,
    follower_description_pl text,
    video_url character varying(255),
    dance_type_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    hands character varying(255),
    count_description character varying(255),
    count_num integer
);


--
-- Name: patterns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.patterns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: patterns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.patterns_id_seq OWNED BY public.patterns.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    body text NOT NULL,
    subject character varying(255),
    tags character varying(255),
    user_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: user_lessons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_lessons (
    id bigint NOT NULL,
    lesson_id bigint NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: user_lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_lessons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_lessons_id_seq OWNED BY public.user_lessons.id;


--
-- Name: user_patterns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_patterns (
    id bigint NOT NULL,
    status character varying(255) DEFAULT 'learning'::character varying NOT NULL,
    user_id bigint NOT NULL,
    pattern_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: user_patterns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_patterns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_patterns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_patterns_id_seq OWNED BY public.user_patterns.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username character varying(255),
    email public.citext NOT NULL,
    role character varying(255) DEFAULT 'student'::character varying NOT NULL,
    course_enrolled boolean DEFAULT false,
    profile_pic_url character varying(255),
    qr_code_url character varying(255),
    hashed_password character varying(255) NOT NULL,
    confirmed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_tokens_id_seq OWNED BY public.users_tokens.id;


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: dance_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dance_types ALTER COLUMN id SET DEFAULT nextval('public.dance_types_id_seq'::regclass);


--
-- Name: lesson_patterns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_patterns ALTER COLUMN id SET DEFAULT nextval('public.lesson_patterns_id_seq'::regclass);


--
-- Name: lessons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons ALTER COLUMN id SET DEFAULT nextval('public.lessons_id_seq'::regclass);


--
-- Name: lessons_instructors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons_instructors ALTER COLUMN id SET DEFAULT nextval('public.lessons_instructors_id_seq'::regclass);


--
-- Name: levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.levels ALTER COLUMN id SET DEFAULT nextval('public.levels_id_seq'::regclass);


--
-- Name: patterns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patterns ALTER COLUMN id SET DEFAULT nextval('public.patterns_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: user_lessons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_lessons ALTER COLUMN id SET DEFAULT nextval('public.user_lessons_id_seq'::regclass);


--
-- Name: user_patterns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_patterns ALTER COLUMN id SET DEFAULT nextval('public.user_patterns_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comments (id, body, user_id, post_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: dance_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dance_types (id, name_pl, description_pl, country_pl, tag_pl, name_en, description_en, country_en, tag_en, type, inserted_at, updated_at, pic_url) FROM stdin;
1	West Coast Swing	Płynny i elastyczny styl tańca swingowego pochodzący z USA.	Stany Zjednoczone	wcs	West Coast Swing	A smooth and elastic swing dance style originating from the U.S.	United States	wcs	swing	2025-11-07 23:36:22	2025-11-07 23:36:22	/images/West-coast-swing.webp
2	Cha-Cha	Żywiołowy taniec latynoamerykański z szybkimi krokami i zabawnym rytmem.	Kuba	cha-cha	Cha-Cha	A lively Latin dance characterized by quick steps and playful rhythm.	Cuba	cha-cha	latin	2025-12-27 21:49:23	2025-12-27 21:49:23	/images/Cha-cha.webp
3	Samba	Żywiołowy brazylijski taniec z podskakującym rytmem, często wykonywany w stylu karnawałowym.	Brazylia	samba	Samba	A lively Brazilian dance with a bouncing rhythm, often performed in carnival style.	Brazil	samba	latin	2025-12-27 21:50:17	2025-12-27 21:50:17	/images/Samba.webp
4	Walc wiedeński	Elegancki i szybki taniec towarzyski w metrum 3/4, znany z płynnych obrotów i wdzięku.	Austria	walc-wiedenski	Viennese Waltz	A graceful and fast ballroom dance in 3/4 time, known for its flowing turns and elegance.	Austria	viennese-waltz	standard	2025-12-27 21:51:54	2025-12-27 21:51:54	/images/Vienna-Valtz.webp
\.


--
-- Data for Name: lesson_patterns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lesson_patterns (id, lesson_id, pattern_id) FROM stdin;
1	3	1
2	3	2
3	4	3
4	5	4
5	6	17
6	9	5
7	10	6
8	11	7
9	12	8
10	15	10
12	21	12
13	22	13
14	23	14
15	25	15
16	27	16
17	7	18
18	8	2
19	17	19
21	19	21
22	19	10
23	20	22
24	14	9
25	15	18
26	16	19
27	7	24
28	17	25
29	20	26
30	23	28
31	24	29
32	26	30
33	27	31
34	28	32
36	29	33
37	30	34
38	31	35
39	34	36
40	34	37
41	35	38
42	36	39
43	36	40
44	37	41
45	39	42
46	42	45
47	43	46
48	46	49
51	50	52
52	51	48
53	52	48
54	53	50
55	54	51
\.


--
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lessons (id, dance_type_id, title, place, level_id, lesson_vid_url, date, inserted_at, updated_at) FROM stdin;
3	1	Lekcja z  2024-10-07	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/KIhYt_AVBko	2024-10-07	2025-11-08 10:44:03	2025-11-08 10:44:03
4	1	Lekcja z  2024-10-14	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/MLg01t4zP0k	2024-10-14	2025-11-08 10:47:34	2025-11-08 10:47:34
5	1	Lekcja z  2024-10-21	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/188phJUMrxM	2024-10-21	2025-11-08 10:48:19	2025-11-08 10:48:19
6	1	Lekcja z  2024-10-28	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/SWPKjM4TSBU	2024-10-28	2025-11-08 10:50:21	2025-11-08 10:50:21
7	1	Lekcja z  2024-11-04	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/111BJALz96o	2024-11-04	2025-11-08 10:51:19	2025-11-08 10:51:19
8	1	Lekcja z  2024-11-18	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/KPZdaqPXn0M	2024-11-18	2025-11-08 10:52:37	2025-11-08 10:52:37
17	1	Lekcja z  2025-03-10	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/Rch2DloIZY0	2025-03-10	2025-11-08 11:07:20	2025-11-08 11:18:22
18	1	Lekcja z  2025-03-17	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/OH8UUS2ToAc	2025-03-17	2025-11-08 11:08:02	2025-11-08 11:18:38
19	1	Lekcja z  2025-03-24	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/X5bo_lp02c8	2025-03-24	2025-11-08 11:08:35	2025-11-08 11:18:51
20	1	Lekcja z  2025-03-31	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/7dJ_tV4CRgk	2025-03-31	2025-11-08 11:08:59	2025-11-08 11:19:05
9	1	Lekcja z  2024-12-02	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/KMnLjdN3pl8	2024-12-02	2025-11-08 10:58:43	2025-11-19 22:18:00
10	1	Lekcja z  2024-12-09	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/jVMGMKXwQuA	2024-12-09	2025-11-08 10:59:18	2025-11-19 22:18:39
11	1	Lekcja z  2024-12-16	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/6LEXfNEELQo	2024-12-16	2025-11-08 10:59:50	2025-11-19 22:19:07
12	1	Lekcja z  2025-01-13	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/1kazlp9K09Y	2025-01-13	2025-11-08 11:01:00	2025-11-19 22:19:34
13	1	Lekcja z  2025-01-20	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/fBy5xZltMFg	2025-01-20	2025-11-08 11:02:05	2025-11-19 22:20:11
14	1	Lekcja z  2025-01-27	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/8w7NQk0yTtE	2025-01-27	2025-11-08 11:02:46	2025-11-19 22:20:42
15	1	Lekcja z  2025-02-17	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/vXvsiNw8lrI	2025-02-17	2025-11-08 11:05:38	2025-11-19 22:21:13
16	1	Lekcja z  2025-03-03	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/zy4VuuKdmCE	2025-03-03	2025-11-08 11:06:50	2025-11-19 22:21:39
21	1	Lekcja z  2025-04-07	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/gmpWbUQ54YM	2025-04-07	2025-11-08 11:09:34	2025-11-19 22:22:11
22	1	Lekcja z  2025-04-14	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/BM_fAc05E14	2025-04-14	2025-11-08 11:10:12	2025-11-19 22:22:38
23	1	Lekcja z  2025-04-28	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/LpXdiCbFOco	2025-04-28	2025-11-08 11:11:06	2025-11-19 22:31:10
24	1	Lekcja z  2025-05-05	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/wCRNx3XFGsw	2025-05-05	2025-11-08 11:11:51	2025-11-19 22:31:58
25	1	Lekcja z  2025-05-12	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/QsfdC3N89gg	2025-05-12	2025-11-08 11:12:27	2025-11-19 22:32:24
26	1	Lekcja z  2025-06-02	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/L1Sx9i_U3nE	2025-06-02	2025-11-08 11:13:00	2025-11-19 22:32:49
27	1	Lekcja z  2025-06-30	Buma Square Business Park, Wadowicka 6	1	https://www.youtube-nocookie.com/embed/TfmrRT0q4Zg	2025-06-30	2025-11-08 11:13:29	2025-11-19 22:33:14
28	1	Lekcja z  2025-10-06	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/QSPLGaqnKjA	2025-10-06	2025-11-08 11:15:10	2025-11-19 22:59:04
29	1	Lekcja z  2025-10-20	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/Yoksl-WB8Zk	2025-10-20	2025-11-08 11:16:01	2025-11-19 22:59:29
30	1	Lekcja z  2025-10-27	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/h3XypVON1sg	2025-10-27	2025-11-08 11:16:36	2025-11-19 23:00:02
31	1	Lekcja z  2025-11-03	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/xVSN_OPYsDU	2025-11-03	2025-11-08 11:17:08	2025-11-19 23:04:26
42	1	Lekcja z  2026-02-09	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/bNFHJbLYtP8	2026-02-09	2026-02-22 19:54:22	2026-02-22 19:54:22
34	1	Lekcja z  2025-11-17	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/rwRHLeLnHec	2025-11-17	2025-11-20 15:32:20	2025-11-20 15:32:20
35	1	Lekcja z  2025-12-01	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/w8FalO7B4ag	2025-12-01	2025-12-27 14:18:01	2025-12-27 14:18:01
36	1	Lekcja z  2025-12-15	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/ak2E3oLPcCc	2025-12-15	2025-12-27 14:19:58	2025-12-27 14:19:58
37	1	Lekcja z  2026-01-12	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/KxT-0zVkkI4	2026-01-12	2026-02-22 19:50:51	2026-02-22 19:50:51
40	1	Lekcja z  2026-02-02	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/TE30Cecnzi8	2026-02-02	2026-02-22 19:53:29	2026-02-22 19:53:29
39	1	Lekcja z  2026-01-26	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/9VIyMJLvtwY	2026-01-26	2026-02-22 19:52:40	2026-02-25 20:20:23
43	1	Lekcja z  2026-03-02	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/20cRRn3xvKk	2026-03-02	2026-03-04 09:26:06	2026-03-04 09:26:06
45	1	Lekcja z  2026-03-09	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/WDwUzE27vEQ	2026-03-09	2026-05-24 14:00:30	2026-05-24 14:01:05
46	1	Lekcja z  2026-03-23	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/8EFMcnDExVo	2026-03-23	2026-05-24 14:01:59	2026-05-24 14:01:59
50	1	Lekcja z  2026-05-11	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/TQgDQ30uzKk	2026-05-11	2026-05-24 14:15:58	2026-05-24 14:15:58
49	1	Lekcja z  2026-04-27	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/qJ7hlDLslS4	2026-04-27	2026-05-24 14:15:11	2026-05-24 14:56:31
44	1	Lekcja z  2026-03-12	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/pEUNRApcqWA	2026-03-12	2026-05-24 13:59:19	2026-05-24 14:16:43
51	1	Lekcja z  2026-03-30	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/P39Mh5R5SPk	2026-03-30	2026-05-24 14:39:07	2026-05-24 14:39:19
52	1	Lekcja z  2026-04-13	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/YmhhPazVB3s	2026-04-13	2026-05-24 14:57:32	2026-05-24 14:57:32
53	1	Lekcja z  2026-04-20	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/kNLHqMjLleM	2026-04-20	2026-05-24 14:59:22	2026-05-24 14:59:22
54	1	Lekcja z  2026-05-04	Buma Square Business Park, Wadowicka 6	2	https://www.youtube-nocookie.com/embed/A_Whd2F-LCc	2026-05-04	2026-05-24 15:00:27	2026-05-24 15:00:27
\.


--
-- Data for Name: lessons_instructors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lessons_instructors (id, lesson_id, instructor_id) FROM stdin;
1	3	2
2	4	2
3	5	2
4	6	2
5	7	2
6	8	2
7	9	2
8	10	2
9	12	2
10	13	2
11	14	2
12	15	2
13	16	2
14	17	2
15	18	2
16	19	2
17	20	2
18	21	2
19	22	2
20	23	2
21	24	2
22	25	2
23	26	2
24	27	2
25	28	2
26	29	2
27	30	2
28	31	2
31	34	2
32	35	2
33	36	2
34	11	2
35	37	2
37	39	2
38	40	2
40	42	2
41	43	2
42	44	2
43	45	2
44	46	2
47	49	2
48	50	2
49	51	2
50	52	2
51	53	2
52	54	2
\.


--
-- Data for Name: levels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.levels (id, name, inserted_at, updated_at) FROM stdin;
1	P1	2025-11-08 10:43:14	2025-11-08 10:43:14
2	P2	2025-11-08 10:43:18	2025-11-08 10:43:18
\.


--
-- Data for Name: patterns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.patterns (id, name, leader_description_en, follower_description_en, leader_description_pl, follower_description_pl, video_url, dance_type_id, inserted_at, updated_at, hands, count_description, count_num) FROM stdin;
33	Roll in with hammerlock	bla bla	\N	\N	\N	\N	1	2026-02-25 19:43:39	2026-02-25 19:43:39	right-right,	1, 2, 3&4, 5&6	6
8	Roll in	6 steps: Prep the follower rolls in three and four and rolls out hook \nmay also and with sugar push	\N	\N	\N	\N	1	2025-11-08 10:21:18	2025-12-27 18:07:40	\N	\N	\N
18	Closed position (exit)	2xSlow + Triple Step(Travel) + Anchor(In Place)	\N	\N	\N	\N	1	2025-11-08 13:51:06	2026-02-23 20:13:14	Pass	1, 2, 3&4, 5&6	6
19	Reverse Whip	Slow(Prep) + Slow(Stretch, Rotation) + Triple Step(In Place) + 2xSlow(Rotation, Replace) + Anchor(In Place)	\N	\N	\N	\N	1	2025-12-27 15:08:19	2026-02-23 20:21:20	Rotation	1, 2, 3&4, 5, 6, 7&8	8
34	2 hands sugar Tuck with Rock and go	bla bla	\N	\N	\N	\N	1	2026-02-25 19:48:27	2026-02-25 19:48:27	both-hands,left-right	1, 2, 3&4, 5&6	6
25	Reverse Whip with rotation	Slow(Prep) + Slow(Stretch, Rotation) + Triple Step(In Place) + 2xSlow(Rotation, Replace) + Anchor(In Place) there is a diverance after 4 spin but how to write it a mystery for future me 	\N	\N	\N	\N	1	2026-02-23 20:23:45	2026-02-23 20:26:37	Whip	1, 2, 3&4, 5, 6, 7&8	8
21	Whip on the back	2xSlow(Travel) + Triple Step(Travel, Pass) + 2xSlow(Rotation) + Anchor(In Place) 	\N	\N	\N	\N	1	2025-12-27 15:46:54	2026-02-23 20:34:54	Whip	1, 2, 3&4, 5, 6, 7&8	8
35	Roll in and Rock and go	bla bla	\N	\N	\N	\N	1	2026-02-25 19:53:20	2026-02-25 19:53:20	left-right,left-right+Rock and Go	1, 2, 3&4, 5&6	6
10	Sunshine push	2xSlow(Prep) + Triple Step(In Place) + A(In Place)	\N	\N	\N	\N	1	2025-11-08 10:22:06	2026-02-23 20:38:48	Compression	1, 2, 3&4, 5&6	6
4	Sugar push	Slow (Stretch) + Slow (Compression) + Triple Step(In place, Compression) + Anchor(In Place)	\N	\N	\N	\N	1	2025-11-08 10:19:42	2026-02-24 15:32:07	left-right,left-right	1,2 3&4, 5&6	6
36	Romatic Push	bla bla	\N	\N	\N	\N	1	2026-02-25 19:59:27	2026-02-25 19:59:27	left-right,left-right	1, 2, 3&4, 5&6, 7&8, 9&10	10
5	Whip	2xSlow + Triple Step(Pivot, Pass) + 2xSlow(In Place) + Anchor(In Place)	\N	\N	\N	\N	1	2025-11-08 10:20:10	2026-02-24 15:32:23	left-right,left-right	1,2 3&4, 5, 6, 7&8	8
6	Free spin	6 steps: Go to the right make room the follower makes a spin and then a hook	\N	\N	\N	\N	1	2025-11-08 10:20:26	2025-12-27 17:34:43	\N	\N	\N
22	Whip on the Back to Shadow	Idk problem for future me 	\N	\N	\N	\N	1	2025-12-27 16:00:57	2026-02-23 20:56:23	Prep	1, 2, 3&4, 5&6	6
7	Spinning pass	6 steps: Right hand to right hand, do prep initialise spin grab left hand and hook \nthere is also a variation where follower slides their arm from shoulder to arm on the end 	\N	\N	\N	\N	1	2025-11-08 10:20:49	2025-12-27 17:49:50	\N	\N	\N
9	Drop	8 steps: like roll in but don't step back stay on the line. The follower rolls in slightly bend your knee rolls out hook 	\N	\N	\N	\N	1	2025-11-08 10:21:40	2025-12-27 17:56:20	\N	\N	\N
23	Chassé	\N	\N	\N	\N	https://www.youtube-nocookie.com/embed/W1k8aCXOch4	2	2025-12-27 22:02:54	2025-12-27 22:03:45	\N	\N	\N
26	Shadow exit	idk	\N	\N	\N	\N	1	2026-02-23 20:56:48	2026-02-23 20:56:48	Travel	idk	8
37	Mystery name 2 that one with hands 	bla bla	\N	\N	\N	\N	1	2026-02-25 20:01:57	2026-02-25 20:01:57	\N	1, 2, 3&4, 5, 6, 7&8	8
1	Left side pass	2xSlow + Triple Step (Travel) + Anchor	2xSlow + Triple Step (Travel) + Anchor	\N	\N	\N	1	2025-11-08 10:18:46	2026-02-24 15:31:14	left-right,left-right	1, 2 3&4, 5&6	6
38	Sugar push with axis change	bla bla	\N	\N	\N	\N	1	2026-02-25 20:04:48	2026-02-25 20:04:48	left-right,left-right	1, 2, 3&4, 5&6	6
12	Show girl	6xSlow	\N	\N	\N	\N	1	2025-11-08 10:23:10	2026-02-24 15:39:37	left-right,left-right	1, 2, 3, 4, 5, 6	6
13	Macho push	2xSlow + Triple Step + Anchor	\N	\N	\N	\N	1	2025-11-08 10:23:26	2026-02-24 15:46:41	right-right,left-right	1, 2, 3&4, 5&6	6
17	Sugar tuck	Slow (Stretch) + Slow (Compression) + Triple Step (Travel, Pass) + Anchor (In Place)	\N	\N	\N	\N	1	2025-11-08 10:49:15	2026-02-24 15:53:49	left-right,left-right	1,2 3&4, 5&6	6
39	Roll in roll out slow clock wariation	bla bla	\N	\N	\N	\N	1	2026-02-25 20:10:02	2026-02-25 20:10:02	left-right,left-right	1, 2, 3&4, 5, 6, 7&8	8
24	Starting Position	6xSlow(In Place) + 2xSlow(Prep) + Triple Step(Traversal) + Anchor	\N	\N	\N	\N	1	2026-02-23 20:09:47	2026-02-23 20:09:47	Prep	1, 2, 3, 4, 5, 6, 7, 8, 9&10, 11&12	12
2	Inside turn	2xSlow (Prep) + Triple Step (In Place, Rotation) + Anchor	\N	\N	\N	\N	1	2025-11-08 10:19:02	2026-02-24 15:31:30	left-right,left-right	1, 2, 3&4, 5&6 	6
3	Under arm	2xSlow (Prep) + Triple Step (Traversal, Rotation) + Anchor (In Place)	\N	\N	\N	\N	1	2025-11-08 10:19:27	2026-02-24 15:31:40	left-right,left-right	1, 2, 3&4, 5&6	6
28	Hammerlock exit (for further research)	ds	\N	\N	\N	\N	1	2026-02-24 15:58:49	2026-02-24 15:58:49	\N	\N	6
14	Hammerlock enter (for furter research)	12 steps: Starts with handing two hands down impulse still keeping hands rolls in, normal prep the follower spins hook 	\N	\N	\N	\N	1	2025-11-08 10:23:44	2026-02-24 15:59:13	\N	\N	\N
29	Mystery name	dsds	\N	\N	\N	\N	1	2026-02-24 16:06:13	2026-02-24 16:06:13	right-right,right-right-crossed	1, 2, 3&4, 5, 6, 7&8	8
40	Roll in roll out fast clock wariation	bla bla	\N	\N	\N	\N	1	2026-02-25 20:10:25	2026-02-25 20:10:25	left-right,left-right	1, 2, 3&4, 5&6	6
15	Wrist catch	bla bla\n	\N	\N	\N	\N	1	2025-11-08 10:24:01	2026-02-25 17:12:15	left-right,left-right	1, 2, 3&4, 5, 6, 7&8	6
30	Wrist catch to closed position	bla bla 	\N	\N	\N	\N	1	2026-02-25 17:13:57	2026-02-25 17:13:57	left-right,closed-position	1, 2, 3&4, 5, 6, 7&8	8
16	Spinning Pass + Rock and go	bla bla	\N	\N	\N	\N	1	2025-11-08 10:24:27	2026-02-25 17:42:44	left-right,rock-and-go	1, 2, 3&4, 5&6	6
31	Closed position (exit) sugar tuck	bla bla	\N	\N	\N	\N	1	2026-02-25 17:29:33	2026-02-25 17:44:13	Closed Position,left-right	1, 2, 3&4, 5&6	6
32	Combo	bla bla	\N	\N	\N	\N	1	2026-02-25 19:40:35	2026-02-25 19:40:35	right-left,Closed Position	1, 2, 3&4, 5, 6, 7&8	8
41	Sugar tuck drop	bla bla\n	\N	\N	\N	\N	1	2026-02-25 20:17:40	2026-02-25 20:17:40	left-right,left-right	1, 2, 3&4, 5, 6, 7&8	8
42	Crosbow whip	bla bla	\N	\N	\N	\N	1	2026-02-25 20:19:31	2026-02-25 20:19:31	right-right,crossed-hands	1, 2, 3&4, 5, 6, 7&8	8
43	Barrer roll fast	bla bla	\N	\N	\N	\N	1	2026-02-25 20:21:02	2026-02-25 20:21:02	left-right,left-right	1, 2, 3&4, 5&6	6
44	Barrer roll slow	bla bla	\N	\N	\N	\N	1	2026-02-25 20:21:22	2026-02-25 20:21:22	left-right,left-right	1, 2, 3&4, 5, 6, 7&8	8
45	sugar tuck to shadow, spinning pass	bla bla	\N	\N	\N	\N	1	2026-02-25 20:23:47	2026-02-25 20:23:47	left-right,left-right	1, 2, 3&4, 5, 6	12
46	Slingshot	bla bla	\N	\N	\N	\N	1	2026-03-04 09:29:25	2026-03-04 09:29:25	left-right,left-right 	1, 2, 3&4, 5&6	6
47	Sugar Tuck Follower variant	sth	\N	\N	\N	\N	1	2026-05-19 20:45:04	2026-05-19 20:45:04	left-left,left-inverted-left	1,2, 3&4 5&6	6
48	Sugar Tuck with hand change 	sth	\N	\N	\N	\N	1	2026-05-19 20:48:14	2026-05-19 20:48:14	left-left,left-left	1,2 3&4 5&6, 7 ,8	8
49	Blues Pattern	sth	\N	\N	\N	\N	1	2026-05-19 20:50:42	2026-05-19 20:50:42	left-right,left-right	1,2 3&4 5&6	6
50	Blues BarelRoll	sth	\N	\N	\N	\N	1	2026-05-19 20:53:24	2026-05-19 20:53:24	left-right,left-right	1,2,3,4,5,6	6
51	Tldr Pattern	sth too long 	\N	\N	\N	\N	1	2026-05-19 20:54:48	2026-05-19 20:54:48	left-right,left-right	1,2,3,4,5,6,7,8	8
52	Roll in roll out gentle escape	sth	\N	\N	\N	\N	1	2026-05-19 20:55:45	2026-05-19 20:55:45	left-right,left-right	1,2,3,4,5,6,7,8	8
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.posts (id, title, body, subject, tags, user_id, inserted_at, updated_at) FROM stdin;
1	Początek	A więc nadeszła ta chwila udało mi się postawić pierwszą stronę internetową na własnym serwerze którym jest biedny HP Pavilion g6. \nNa razie działa super nie narzekam.\nCzy powinno być po angielsku być może, ale co tam\nBędzie tu taniec dużo tańca dużo swinga jak strona wytrzyma miesiąc to będę mile zaskoczony jeszcze kilka bugów jest do naprawy nie są krytyczne to trudno. No i spolszczenie jest okropne ale to już moja wina.\nLiczę na taniec dużo tańca ╾━╤デ╦︻(▀̿Ĺ̯▀̿ ̿) \n	początek	:starting:phoenix:announcment	1	2025-11-07 23:56:51	2025-11-08 13:06:07
2	Leading Projection 	Did you ever wondered whether the follower may have any input into selecting future steps. So yeah they can! It is called Leading projection what basically means that follower after hook stays on the left center or right and the leader have to put into considerations steps that they may start from given position so it looks neet and nice. It's basically react to what your partner do. Enjoy glhf  	Wcs 	Wcs:leader:follower	1	2025-12-27 15:36:05	2025-12-27 15:36:05
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20251025123720	2025-11-07 22:23:11
20260223154111	2026-02-23 17:36:32
20260223211210	2026-02-23 21:57:47
\.


--
-- Data for Name: user_lessons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_lessons (id, lesson_id, user_id) FROM stdin;
3	5	1
4	6	1
6	4	1
33	7	1
34	3	1
36	8	1
37	17	1
39	18	1
40	19	1
41	20	1
42	9	1
44	10	1
45	11	1
46	12	1
47	13	1
48	14	1
49	15	1
50	16	1
51	21	1
52	22	1
53	23	1
54	24	1
55	25	1
56	26	1
57	27	1
58	28	1
59	30	1
60	29	1
61	31	1
62	34	1
63	35	1
64	36	1
65	37	1
66	39	1
67	40	1
68	42	1
\.


--
-- Data for Name: user_patterns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_patterns (id, status, user_id, pattern_id, inserted_at, updated_at) FROM stdin;
1	learned	1	1	2025-11-10 14:23:42	2025-11-10 14:24:40
2	learned	1	2	2025-11-19 22:00:03	2025-11-19 22:00:09
3	in_progress	1	3	2025-11-19 22:00:21	2025-11-19 22:00:21
4	learned	1	23	2025-12-28 22:53:17	2025-12-28 22:53:39
5	learned	3	19	2026-03-01 10:01:10	2026-03-01 10:01:12
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, username, email, role, course_enrolled, profile_pic_url, qr_code_url, hashed_password, confirmed_at, inserted_at, updated_at) FROM stdin;
2	Instructor	instructor@mail.com	instructor	f	images/user_icon.png	images/default_qr_code.png	$2b$12$dVh0d5pQM0qPmh.RzQ0RFO8ksGGQaQRz/6GIhRxo5hQEGc6znhCNS	\N	2025-11-08 10:34:40	2025-11-08 10:34:40
3	pati	patrycjatomk@gmail.com	admin	f	images/user_icon.png	images/default_qr_code.png	$2b$12$eX456WYhT5t1iM36TgedAuAYqiaA4e6iUyvhpDROjF.2Xb8FztsFa	\N	2025-11-08 11:22:13	2025-11-08 11:22:13
4	test	test3@mail.com	user	f	images/user_icon.png	images/default_qr_code.png	$2b$12$F08jyqIM3RNiK/1aL9fKzO7/4xV1zPozrHeV8UnNui.jM8UBE98zu	\N	2025-11-09 14:52:48	2025-11-09 14:52:48
13	Swanesse	tawatox716@chaineor.com	user	f	/uploads/profile_1762872884646_c24b2a17-cf51-4c97-bd3d-d7d6a421abb0.webp	/images/default_qr_code.png	$2b$12$0dHKIYnljtV6n3dCUVaL/u0BQ/U2gcc5X.CLKdtceVR2ja1qt5wOi	\N	2025-11-11 14:51:49	2025-11-11 14:54:45
1	karolszarooki	karol.szarooki@gmail.com	admin	f	/uploads/profile_1763652607218_1e14b95e-791b-41fa-baf4-fd9f448ba2b5.webp	images/default_qr_code.png	$2b$12$jU/6sqfpoqX4UL9mCn.aIeJ0K/jHifRuHn9ZGR720AIHuPG9yNV0W	\N	2025-11-07 23:37:46	2025-11-20 15:30:07
\.


--
-- Data for Name: users_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users_tokens (id, user_id, token, context, sent_to, inserted_at) FROM stdin;
1	1	\\x3b6e52065f8021ad95947d46fb43c87ad6deb775cba14d8dce36a24d7c849d46	confirm	karol.szarooki@gmail.com	2025-11-07 23:37:46
2	1	\\xf5ec025b2037cca75116637c07e0d301eda90093566044cbe9ec07ba7c2b00e9	session	\N	2025-11-07 23:38:47
4	2	\\x8008fe7f2ccde5045acdc45b1b4c3d06a71770db129a1b24bd0a77c03d9980fb	confirm	instructor@mail.com	2025-11-08 10:34:40
6	3	\\xc7b26a1329b3659cb7989b1f4bbbf94b236e4280e3a41a16a9499be44bf1b18a	confirm	patrycjatomk@gmail.com	2025-11-08 11:22:13
9	1	\\x4891114a2130c788afd8f05688b0c4da41f69d7b618ceb4aaed9fb416daf9eb9	session	\N	2025-11-08 11:37:01
10	4	\\x2e19c4724b1a1c62d2f87150a3a72a5b98d60f203e3862cc8274470d3fd59b8e	confirm	test3@mail.com	2025-11-09 14:52:48
21	4	\\x0fc680a34ab9dce3503592c05d75e9354c774af424f285711ba69999e7e503df	session	\N	2025-11-10 12:40:35
22	1	\\x12701bc784176f7019f46a38e63b2eda446d3715b14dd3b9df455bd45fa3cddc	session	\N	2025-11-10 16:32:18
23	3	\\x5fe1be90ec09758e8e97f7b11545b948c58a6303ff60726d1568cfae180ce1f6	session	\N	2025-11-10 18:00:40
24	1	\\x7caa7c0d0c38154eb6c385cf6ee913c9fd161d248f422a368d10af012b1e8191	session	\N	2025-11-10 21:01:15
25	13	\\xc1cc4d219f410fe5b113c476272a4cc9234e1728d738b8b6449e5161e2c21e73	confirm	tawatox716@chaineor.com	2025-11-11 14:51:49
26	13	\\x209c273c1549090638f506cf7e76d9ea25f4e783cca5e14298a8ea292721d97b	session	\N	2025-11-11 14:53:07
28	1	\\x90f8da9252bc2d655b5824400cb374b4bc2017f33d869c6c6da09a2e58e1244a	session	\N	2025-11-19 19:33:42
29	1	\\x2676444f568512ab24d47f6640cfad8ca2639f0286a1f83f3519c6aaad3864a2	session	\N	2025-11-19 19:35:32
30	3	\\x2b18f774b526a75ae3a38666558c27b93df94f911007d43f8e846b433e039bca	session	\N	2025-12-28 22:51:19
31	1	\\x0aff28535abc691718a743e7b8d0e6cee0797f59d40bffe8c3db82cbcbe8a9e9	session	\N	2025-12-29 14:56:04
32	1	\\xcf90165dd08e4491c8598fcdbdca4ac35abadd7a09d4de6602f2232b425db3d2	session	\N	2026-01-18 19:42:47
33	1	\\xc3ed4d1723c884cc626b2d2e16ef4696a3995dab51996a8ed870b7fc6bc5629f	session	\N	2026-02-23 17:42:08
34	3	\\x51dee5d07ff48c611e699ceeaefd70ece2f518502242eeb3af3125b38e56721c	session	\N	2026-03-01 09:58:33
35	1	\\x89841dd22ade428c6578b7e9d59a5d37ef39536989828c4947fefdcdf747a2c1	session	\N	2026-04-14 20:58:27
36	3	\\xa21ef53a3742bf54dc204c1270a89511ba4e5040a3c174be4cfc6301d8971d11	session	\N	2026-05-24 15:42:23
\.


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.comments_id_seq', 1, false);


--
-- Name: dance_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dance_types_id_seq', 4, true);


--
-- Name: lesson_patterns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lesson_patterns_id_seq', 55, true);


--
-- Name: lessons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lessons_id_seq', 54, true);


--
-- Name: lessons_instructors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lessons_instructors_id_seq', 52, true);


--
-- Name: levels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.levels_id_seq', 2, true);


--
-- Name: patterns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.patterns_id_seq', 52, true);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.posts_id_seq', 2, true);


--
-- Name: user_lessons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_lessons_id_seq', 68, true);


--
-- Name: user_patterns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_patterns_id_seq', 5, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 13, true);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_tokens_id_seq', 36, true);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: dance_types dance_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dance_types
    ADD CONSTRAINT dance_types_pkey PRIMARY KEY (id);


--
-- Name: lesson_patterns lesson_patterns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_patterns
    ADD CONSTRAINT lesson_patterns_pkey PRIMARY KEY (id);


--
-- Name: lessons_instructors lessons_instructors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons_instructors
    ADD CONSTRAINT lessons_instructors_pkey PRIMARY KEY (id);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (id);


--
-- Name: patterns patterns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patterns
    ADD CONSTRAINT patterns_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: user_lessons user_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_lessons
    ADD CONSTRAINT user_lessons_pkey PRIMARY KEY (id);


--
-- Name: user_patterns user_patterns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_patterns
    ADD CONSTRAINT user_patterns_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_tokens users_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_pkey PRIMARY KEY (id);


--
-- Name: comments_post_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_post_id_index ON public.comments USING btree (post_id);


--
-- Name: comments_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_user_id_index ON public.comments USING btree (user_id);


--
-- Name: dance_types_name_en_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dance_types_name_en_index ON public.dance_types USING btree (name_en);


--
-- Name: dance_types_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX dance_types_type_index ON public.dance_types USING btree (type);


--
-- Name: lesson_patterns_lesson_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lesson_patterns_lesson_id_index ON public.lesson_patterns USING btree (lesson_id);


--
-- Name: lesson_patterns_lesson_id_pattern_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lesson_patterns_lesson_id_pattern_id_index ON public.lesson_patterns USING btree (lesson_id, pattern_id);


--
-- Name: lesson_patterns_pattern_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lesson_patterns_pattern_id_index ON public.lesson_patterns USING btree (pattern_id);


--
-- Name: lessons_dance_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lessons_dance_type_id_index ON public.lessons USING btree (dance_type_id);


--
-- Name: lessons_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lessons_date_index ON public.lessons USING btree (date);


--
-- Name: lessons_instructors_instructor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lessons_instructors_instructor_id_index ON public.lessons_instructors USING btree (instructor_id);


--
-- Name: lessons_instructors_lesson_id_instructor_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lessons_instructors_lesson_id_instructor_id_index ON public.lessons_instructors USING btree (lesson_id, instructor_id);


--
-- Name: lessons_level_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX lessons_level_id_index ON public.lessons USING btree (level_id);


--
-- Name: levels_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX levels_name_index ON public.levels USING btree (name);


--
-- Name: patterns_dance_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patterns_dance_type_id_index ON public.patterns USING btree (dance_type_id);


--
-- Name: patterns_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX patterns_name_index ON public.patterns USING btree (name);


--
-- Name: posts_subject_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_subject_index ON public.posts USING btree (subject);


--
-- Name: posts_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_user_id_index ON public.posts USING btree (user_id);


--
-- Name: user_lessons_lesson_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_lessons_lesson_id_index ON public.user_lessons USING btree (lesson_id);


--
-- Name: user_lessons_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_lessons_user_id_index ON public.user_lessons USING btree (user_id);


--
-- Name: user_lessons_user_id_lesson_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_lessons_user_id_lesson_id_index ON public.user_lessons USING btree (user_id, lesson_id);


--
-- Name: user_patterns_pattern_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_patterns_pattern_id_index ON public.user_patterns USING btree (pattern_id);


--
-- Name: user_patterns_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_patterns_user_id_index ON public.user_patterns USING btree (user_id);


--
-- Name: user_patterns_user_id_pattern_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_patterns_user_id_pattern_id_index ON public.user_patterns USING btree (user_id, pattern_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: users_username_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_username_index ON public.users USING btree (username);


--
-- Name: comments comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: lesson_patterns lesson_patterns_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_patterns
    ADD CONSTRAINT lesson_patterns_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- Name: lesson_patterns lesson_patterns_pattern_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_patterns
    ADD CONSTRAINT lesson_patterns_pattern_id_fkey FOREIGN KEY (pattern_id) REFERENCES public.patterns(id) ON DELETE CASCADE;


--
-- Name: lessons lessons_dance_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_dance_type_id_fkey FOREIGN KEY (dance_type_id) REFERENCES public.dance_types(id) ON DELETE CASCADE;


--
-- Name: lessons_instructors lessons_instructors_instructor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons_instructors
    ADD CONSTRAINT lessons_instructors_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: lessons_instructors lessons_instructors_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons_instructors
    ADD CONSTRAINT lessons_instructors_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- Name: lessons lessons_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.levels(id) ON DELETE CASCADE;


--
-- Name: patterns patterns_dance_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patterns
    ADD CONSTRAINT patterns_dance_type_id_fkey FOREIGN KEY (dance_type_id) REFERENCES public.dance_types(id) ON DELETE CASCADE;


--
-- Name: posts posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_lessons user_lessons_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_lessons
    ADD CONSTRAINT user_lessons_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- Name: user_lessons user_lessons_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_lessons
    ADD CONSTRAINT user_lessons_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_patterns user_patterns_pattern_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_patterns
    ADD CONSTRAINT user_patterns_pattern_id_fkey FOREIGN KEY (pattern_id) REFERENCES public.patterns(id) ON DELETE CASCADE;


--
-- Name: user_patterns user_patterns_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_patterns
    ADD CONSTRAINT user_patterns_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict U1R42op2CpsxBAp2vkypvvScywsZiUf2ZIDcnL8f897XimrglzAdQJ2IVYYC7Mw

