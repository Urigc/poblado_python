--
-- PostgreSQL database dump
--

\restrict 6wjQXY5YBAUlJcxGzgnXm6uC3XQhJmza6tSNiqQJ32uPCoqg3k7Du6Hu2AmUKLE

-- Dumped from database version 17.7 (Debian 17.7-3.pgdg13+1)
-- Dumped by pg_dump version 18.1

-- Started on 2026-03-21 17:42:52 CST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 226 (class 1259 OID 16495)
-- Name: acta_entrega; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acta_entrega (
    id_acta character(10) NOT NULL,
    acta_entrega text NOT NULL,
    fecha_expedicion date NOT NULL,
    id_obra character(20) NOT NULL
);


--
-- TOC entry 218 (class 1259 OID 16400)
-- Name: constructora; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.constructora (
    id_constructora character(10) NOT NULL,
    rfc character(12),
    nombre_const character(150) NOT NULL,
    tipo_ejecutor character(100) NOT NULL
);


--
-- TOC entry 229 (class 1259 OID 16538)
-- Name: costos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.costos (
    id_gasto character(20) NOT NULL,
    categoria character(200) NOT NULL,
    costo numeric(8,2) NOT NULL,
    descripcion text NOT NULL,
    id_presupuesto character(10) NOT NULL
);


--
-- TOC entry 230 (class 1259 OID 16557)
-- Name: financia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.financia (
    id_obra character(20) NOT NULL,
    id_fuente character(10) NOT NULL
);


--
-- TOC entry 227 (class 1259 OID 16507)
-- Name: firmantes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.firmantes (
    id_firmante character(10) NOT NULL,
    nombre character(100) NOT NULL,
    apellido_paterno character(200) NOT NULL,
    apellido_materno character(200),
    cargo character(100) NOT NULL,
    id_acta character(10) NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 16407)
-- Name: fuente_presupuestaria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fuente_presupuestaria (
    id_fuente character(10) NOT NULL,
    grado_nivel character(50) NOT NULL,
    programa text NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 16519)
-- Name: informes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.informes (
    id_informe character(20) NOT NULL,
    ano_infor integer NOT NULL,
    mes character(30) NOT NULL,
    porcentaje_avance_fisico smallint NOT NULL,
    porcentaje_avance_presupuestario smallint NOT NULL,
    doc_infome text NOT NULL,
    descripcion text NOT NULL,
    id_obra character(20) NOT NULL,
    codigo_supervisor character(20) NOT NULL,
    CONSTRAINT fisicpositivo CHECK (((porcentaje_avance_fisico >= 0) AND (porcentaje_avance_fisico <= 100))),
    CONSTRAINT monetpositivo CHECK (((porcentaje_avance_presupuestario >= 0) AND (porcentaje_avance_presupuestario <= 100)))
);


--
-- TOC entry 224 (class 1259 OID 16458)
-- Name: obra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.obra (
    id_obra character(20) NOT NULL,
    codigo_expediente character(15) NOT NULL,
    nombre_obra character(200) NOT NULL,
    etapa smallint,
    fecha_inicio date NOT NULL,
    fecha_final date NOT NULL,
    descripcion text NOT NULL,
    beneficiarios text NOT NULL,
    id_constructora character(10) NOT NULL,
    id_region character(5) NOT NULL,
    codigo_supervisor character(20) NOT NULL,
    CONSTRAINT fechadiferente CHECK ((fecha_inicio < fecha_final))
);


--
-- TOC entry 225 (class 1259 OID 16483)
-- Name: opcion_seleccion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.opcion_seleccion (
    id_participante character(10) NOT NULL,
    constructora character(200) NOT NULL,
    aprobado boolean NOT NULL,
    razones_decision text NOT NULL,
    id_obra character(20) NOT NULL
);


--
-- TOC entry 231 (class 1259 OID 16572)
-- Name: permisos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permisos (
    id_oficio character(20) NOT NULL,
    nombre_instancia character(200) NOT NULL,
    oficio_acreditacion text NOT NULL,
    id_obra character(20) NOT NULL
);


--
-- TOC entry 220 (class 1259 OID 16414)
-- Name: personal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.personal (
    codigo_personal character(20) NOT NULL,
    nombre character(100) NOT NULL,
    apellido_paterno character(200) NOT NULL,
    apellido_materno character(200)
);


--
-- TOC entry 223 (class 1259 OID 16448)
-- Name: presupuesto_obra; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.presupuesto_obra (
    id_presupuesto character(10) NOT NULL,
    presupuesto_total numeric(12,3) NOT NULL,
    id_proyectista character(20) NOT NULL,
    id_obra character(20) NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 16421)
-- Name: proyectista; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proyectista (
    codigo_personal character(20) NOT NULL,
    empresa character(150) NOT NULL,
    id_constructora character(10) NOT NULL
);


--
-- TOC entry 217 (class 1259 OID 16393)
-- Name: region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region (
    id_region character(5) NOT NULL,
    comunidad character(50) NOT NULL,
    barrio character(150) NOT NULL,
    colonia text
);


--
-- TOC entry 222 (class 1259 OID 16436)
-- Name: supervisor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.supervisor (
    codigo_personal character(20) NOT NULL,
    telefono text
);


--
-- TOC entry 3357 (class 2606 OID 16501)
-- Name: acta_entrega acta_entrega_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acta_entrega
    ADD CONSTRAINT acta_entrega_pkey PRIMARY KEY (id_acta);


--
-- TOC entry 3335 (class 2606 OID 16404)
-- Name: constructora constructora_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constructora
    ADD CONSTRAINT constructora_pkey PRIMARY KEY (id_constructora);


--
-- TOC entry 3365 (class 2606 OID 16544)
-- Name: costos costos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.costos
    ADD CONSTRAINT costos_pkey PRIMARY KEY (id_gasto);


--
-- TOC entry 3351 (class 2606 OID 16467)
-- Name: obra expunico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obra
    ADD CONSTRAINT expunico UNIQUE (codigo_expediente);


--
-- TOC entry 3363 (class 2606 OID 16527)
-- Name: informes financia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.informes
    ADD CONSTRAINT financia_pkey PRIMARY KEY (id_informe);


--
-- TOC entry 3361 (class 2606 OID 16513)
-- Name: firmantes firmantes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.firmantes
    ADD CONSTRAINT firmantes_pkey PRIMARY KEY (id_firmante);


--
-- TOC entry 3339 (class 2606 OID 16413)
-- Name: fuente_presupuestaria fuente_presupuestaria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fuente_presupuestaria
    ADD CONSTRAINT fuente_presupuestaria_pkey PRIMARY KEY (id_fuente);


--
-- TOC entry 3367 (class 2606 OID 16561)
-- Name: financia id_rel_fuente_obra; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financia
    ADD CONSTRAINT id_rel_fuente_obra PRIMARY KEY (id_obra, id_fuente);


--
-- TOC entry 3353 (class 2606 OID 16465)
-- Name: obra obra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obra
    ADD CONSTRAINT obra_pkey PRIMARY KEY (id_obra);


--
-- TOC entry 3355 (class 2606 OID 16489)
-- Name: opcion_seleccion opcion_seleccion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opcion_seleccion
    ADD CONSTRAINT opcion_seleccion_pkey PRIMARY KEY (id_participante);


--
-- TOC entry 3369 (class 2606 OID 16578)
-- Name: permisos permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_pkey PRIMARY KEY (id_oficio);


--
-- TOC entry 3341 (class 2606 OID 16420)
-- Name: personal personal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal
    ADD CONSTRAINT personal_pkey PRIMARY KEY (codigo_personal);


--
-- TOC entry 3347 (class 2606 OID 16452)
-- Name: presupuesto_obra presupuesto_obra_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presupuesto_obra
    ADD CONSTRAINT presupuesto_obra_pkey PRIMARY KEY (id_presupuesto);


--
-- TOC entry 3349 (class 2606 OID 16590)
-- Name: presupuesto_obra presupuesto_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presupuesto_obra
    ADD CONSTRAINT presupuesto_unico UNIQUE (id_obra);


--
-- TOC entry 3343 (class 2606 OID 16425)
-- Name: proyectista proyectista_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proyectista
    ADD CONSTRAINT proyectista_pkey PRIMARY KEY (codigo_personal);


--
-- TOC entry 3359 (class 2606 OID 16556)
-- Name: acta_entrega re_1_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acta_entrega
    ADD CONSTRAINT re_1_1 UNIQUE (id_obra);


--
-- TOC entry 3333 (class 2606 OID 16399)
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id_region);


--
-- TOC entry 3337 (class 2606 OID 16406)
-- Name: constructora rfc_unico; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constructora
    ADD CONSTRAINT rfc_unico UNIQUE (rfc);


--
-- TOC entry 3345 (class 2606 OID 16442)
-- Name: supervisor supervisor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supervisor
    ADD CONSTRAINT supervisor_pkey PRIMARY KEY (codigo_personal);


--
-- TOC entry 3375 (class 2606 OID 16473)
-- Name: obra constructora; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obra
    ADD CONSTRAINT constructora FOREIGN KEY (id_constructora) REFERENCES public.constructora(id_constructora) ON UPDATE CASCADE;


--
-- TOC entry 3384 (class 2606 OID 16562)
-- Name: financia fuente_presup; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financia
    ADD CONSTRAINT fuente_presup FOREIGN KEY (id_fuente) REFERENCES public.fuente_presupuestaria(id_fuente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3373 (class 2606 OID 16584)
-- Name: presupuesto_obra obra_rel; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presupuesto_obra
    ADD CONSTRAINT obra_rel FOREIGN KEY (id_obra) REFERENCES public.obra(id_obra) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3383 (class 2606 OID 16545)
-- Name: costos presupuesto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.costos
    ADD CONSTRAINT presupuesto FOREIGN KEY (id_presupuesto) REFERENCES public.presupuesto_obra(id_presupuesto) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3374 (class 2606 OID 16453)
-- Name: presupuesto_obra proyectistacargo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.presupuesto_obra
    ADD CONSTRAINT proyectistacargo FOREIGN KEY (id_proyectista) REFERENCES public.proyectista(codigo_personal) ON UPDATE CASCADE;


--
-- TOC entry 3376 (class 2606 OID 16478)
-- Name: obra region; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obra
    ADD CONSTRAINT region FOREIGN KEY (id_region) REFERENCES public.region(id_region) ON UPDATE CASCADE;


--
-- TOC entry 3380 (class 2606 OID 16550)
-- Name: firmantes rel_acta; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.firmantes
    ADD CONSTRAINT rel_acta FOREIGN KEY (id_acta) REFERENCES public.acta_entrega(id_acta) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3370 (class 2606 OID 16431)
-- Name: proyectista rel_const; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proyectista
    ADD CONSTRAINT rel_const FOREIGN KEY (id_constructora) REFERENCES public.constructora(id_constructora);


--
-- TOC entry 3379 (class 2606 OID 16502)
-- Name: acta_entrega rel_obra; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acta_entrega
    ADD CONSTRAINT rel_obra FOREIGN KEY (id_acta) REFERENCES public.obra(id_obra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3385 (class 2606 OID 16567)
-- Name: financia rel_obra; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.financia
    ADD CONSTRAINT rel_obra FOREIGN KEY (id_obra) REFERENCES public.obra(id_obra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3381 (class 2606 OID 16528)
-- Name: informes rel_obra; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.informes
    ADD CONSTRAINT rel_obra FOREIGN KEY (id_obra) REFERENCES public.obra(id_obra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3378 (class 2606 OID 16490)
-- Name: opcion_seleccion rel_obra; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.opcion_seleccion
    ADD CONSTRAINT rel_obra FOREIGN KEY (id_obra) REFERENCES public.obra(id_obra) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3386 (class 2606 OID 16579)
-- Name: permisos rel_obra; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT rel_obra FOREIGN KEY (id_obra) REFERENCES public.obra(id_obra) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3382 (class 2606 OID 16533)
-- Name: informes rel_sup; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.informes
    ADD CONSTRAINT rel_sup FOREIGN KEY (codigo_supervisor) REFERENCES public.supervisor(codigo_personal) ON UPDATE CASCADE;


--
-- TOC entry 3371 (class 2606 OID 16426)
-- Name: proyectista subclass; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proyectista
    ADD CONSTRAINT subclass FOREIGN KEY (codigo_personal) REFERENCES public.personal(codigo_personal) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3372 (class 2606 OID 16443)
-- Name: supervisor subclass; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.supervisor
    ADD CONSTRAINT subclass FOREIGN KEY (codigo_personal) REFERENCES public.personal(codigo_personal) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3377 (class 2606 OID 16468)
-- Name: obra supervisor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obra
    ADD CONSTRAINT supervisor FOREIGN KEY (codigo_supervisor) REFERENCES public.supervisor(codigo_personal) ON UPDATE CASCADE;


-- Completed on 2026-03-21 17:42:52 CST

--
-- PostgreSQL database dump complete
--

