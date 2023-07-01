-----------------------
-- Relação: Usuário  --
-----------------------
CREATE TABLE usuario (
  nome varchar(16) NOT NULL,
  senha varchar(144) NOT NULL,
  email varchar(254),
  admin bool NOT NULL DEFAULT false,
  -- Chave primária é o próprio nome de usuário
  CONSTRAINT pk_usuario PRIMARY KEY (nome),
  -- Garantia de que o nome de usuário tem pelo menos 3 caracteres
  CONSTRAINT ck_nome CHECK(char_length(nome) >= 3),
  CONSTRAINT ck_admin_email CHECK (
    admin = false -- Restrição aplica apenas à admins
    or (
      admin = true
      and email is not null
    ) -- Caso seja admin, email não pode ser nulo
  ),
  -- Verifica estrutura do email (se não for nulo) contra regex
  CONSTRAINT ck_proper_email CHECK (
    email IS NULL
    OR email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'
  )
);

-----------------------
-- Relação: Feedback --
-----------------------
-- Sequência para gerar IDs de feedback
CREATE SEQUENCE feedback_id_seq START 1 AS bigint;

-- Tabela de feedback
CREATE TABLE feedback (
  id bigint NOT NULL DEFAULT nextval('feedback_id_seq'),
  -- ID automático gerado pela sequência
  horario timestamp NOT NULL DEFAULT now(),
  mensagem varchar(4096) NOT NULL,
  fechamento timestamp,
  usuario varchar(16) NOT NULL,
  -- Chave primária autogerada
  CONSTRAINT pk_feedback PRIMARY KEY (id),
  -- Chave candidata de horário e usuário 
  CONSTRAINT uk_feedback_horario_usuario UNIQUE (horario, usuario),
  -- Chave estrangeira para usuário
  CONSTRAINT fk_feedback_usuario FOREIGN KEY (usuario) REFERENCES usuario (nome) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Check de fechamento (não pode ser anterior ao horário de criação)
  CONSTRAINT ck_fechamento CHECK (
    fechamento IS NULL
    OR fechamento >= horario
  )
);

ALTER SEQUENCE feedback_id_seq OWNED BY feedback.id;

-----------------------------------
-- Relação: VisualizaçãoFeedback --
-----------------------------------
CREATE TABLE visualizacaofeedback (
  administrador varchar(16) NOT NULL,
  feedback bigint NOT NULL,
  horario timestamp NOT NULL DEFAULT now(),
  -- Chave primária composta por administrador, feedback e horário
  CONSTRAINT pk_visualizacaofeedback PRIMARY KEY (administrador, feedback, horario),
  -- Chave estrangeira para usuário (administrador)
  CONSTRAINT fk_visualizacaofeedback_adm FOREIGN KEY (administrador) REFERENCES usuario (nome) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Chave estrangeira para feedback
  CONSTRAINT fk_visualizacaofeedback_feedback FOREIGN KEY (feedback) REFERENCES feedback(id) ON DELETE CASCADE ON UPDATE CASCADE
);

------------------------
-- Relação: Banimento --
------------------------
CREATE TABLE banimento (
  responsavel varchar(16) NOT NULL,
  banido varchar(16) NOT NULL,
  horario timestamp NOT NULL,
  validade timestamp,
  causa varchar(4096),
  -- Chave primária composta por responsável, banido e horário
  CONSTRAINT pk_banimento PRIMARY KEY(responsavel, banido, horario),
  -- Chave estrangeira para usuário (administrador responsável pelo banimento)
  CONSTRAINT fk_banimento_responsavel FOREIGN KEY(responsavel) REFERENCES usuario (nome) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Chave estrangeira para usuário (usuário banido)
  CONSTRAINT fk_banimento_banido FOREIGN KEY(banido) REFERENCES usuario (nome) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Check para garantir que a validade não seja anterior ao horário de banimento
  CONSTRAINT ck_banimento_validade CHECK (
    validade IS NULL
    OR validade >= horario
  )
);

------------------------
-- Relação: Categoria --
------------------------
-- Sequência para gerar IDs de categoria 
CREATE SEQUENCE categoria_id_seq START 1 AS bigint;

-- Tabela de categoria
CREATE TABLE categoria (
  id bigint NOT NULL DEFAULT nextval('categoria_id_seq'),
  nome varchar(100) NOT NULL,
  descricao text NOT NULL,
  icone varchar(2048),
  -- URL do ícone
  -- Chave primária autogerada
  CONSTRAINT pk_categoria PRIMARY KEY (id),
  -- Check para garantir que o ícone seja uma URL válida
  CONSTRAINT ck_categoria_icone CHECK (
    icone IS NULL
    OR icone ~* '^https?://'
  )
);

ALTER SEQUENCE categoria_id_seq OWNED BY categoria.id;

--------------------
-- Relação: Curso --
--------------------
-- Sequência para gerar IDs de curso
CREATE SEQUENCE curso_id_seq START 1 AS bigint;

-- Tabela de curso
CREATE TABLE curso (
  id bigint NOT NULL DEFAULT nextval('curso_id_seq'),
  nome varchar(100) NOT NULL,
  descricao text NOT NULL,
  categoria bigint NOT NULL,
  -- Chave primária autogerada
  CONSTRAINT pk_curso PRIMARY KEY(id),
  -- Chave estrangeira para categoria
  CONSTRAINT fk_curso_categoria FOREIGN KEY(categoria) REFERENCES categoria (id) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER SEQUENCE curso_id_seq OWNED BY curso.id;

----------------------
-- Relação: Unidade --
----------------------
-- Sequência para gerar IDs de unidade
CREATE SEQUENCE unidade_id_seq START 1 AS bigint;

-- Tabela de unidade
CREATE TABLE unidade (
  id bigint NOT NULL DEFAULT nextval('unidade_id_seq'),
  nome varchar(100) NOT NULL,
  descricao text NOT NULL,
  curso bigint NOT NULL,
  -- Chave primária autogerada
  CONSTRAINT pk_unidade PRIMARY KEY(id),
  -- Chave estrangeira para curso
  CONSTRAINT fk_unidade_curso FOREIGN KEY(curso) REFERENCES curso (id) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER SEQUENCE unidade_id_seq OWNED BY unidade.id;

---------------------
-- Relação: Topico --
---------------------
-- Sequência para gerar IDs de tópico
CREATE SEQUENCE topico_id_seq START 1 AS bigint;

-- Tabela de tópico
CREATE TABLE topico (
  id bigint NOT NULL DEFAULT nextval('topico_id_seq'),
  nome varchar(100) NOT NULL,
  descricao text NOT NULL,
  ordem smallint NOT NULL,
  unidade bigint NOT NULL,
  -- Chave primária autogerada
  CONSTRAINT pk_topico PRIMARY KEY(id),
  -- Chave estrangeira para unidade
  CONSTRAINT fk_topico_unidade FOREIGN KEY(unidade) REFERENCES unidade (id) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER SEQUENCE topico_id_seq OWNED BY topico.id;

-----------------------
-- Relação: Conteúdo --
-----------------------
-- Sequência para gerar IDs de conteúdo
CREATE SEQUENCE conteudo_id_seq START 1 AS bigint;

CREATE TABLE conteudo (
  id bigint NOT NULL DEFAULT nextval('conteudo_id_seq'),
  titulo varchar(100) NOT NULL,
  subtitulo varchar(150) NOT NULL,
  duracao integer NOT NULL,
  topico bigint NOT NULL,
  tipo char(1) NOT NULL,
  -- Chave primária autogerada
  CONSTRAINT pk_conteudo PRIMARY KEY(id),
  -- Chave estrangeira para tópico
  CONSTRAINT fk_conteudo_topico FOREIGN KEY(topico) REFERENCES topico(id) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Check para garantir que o tipo seja um dos valores válidos
  -- (A = artigo, V = vídeo, E = exercício) 
  -- O uso de um tipo "enum" também é possível
  CONSTRAINT ck_tipo CHECK (tipo IN ('A', 'V', 'E'))
);

ALTER SEQUENCE conteudo_id_seq OWNED BY conteudo.id;

---------------------
-- Relação: Artigo --
---------------------
CREATE TABLE artigo (
  id bigint NOT NULL,
  corpo text NOT NULL,
  -- Chave primária do conteúdo
  CONSTRAINT pk_artigo PRIMARY KEY(id),
  -- Chave estrangeira para conteúdo
  CONSTRAINT fk_artigo FOREIGN KEY(id) REFERENCES conteudo(id) ON DELETE CASCADE ON UPDATE CASCADE
);

--------------------
-- Relação: Vídeo --
--------------------
CREATE TABLE video (
  id bigint NOT NULL,
  url varchar(2096) NOT NULL,
  descricao text NOT NULL,
  -- Chave primária do conteúdo
  CONSTRAINT pk_video PRIMARY KEY(id),
  -- Chave estrangeira para conteúdo
  CONSTRAINT fk_video FOREIGN KEY(id) REFERENCES conteudo(id) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Check para garantir que a URL seja válida
  CONSTRAINT ck_video_url CHECK (url ~* '^https?://')
);

------------------------
-- Relação: Exercício --
------------------------
CREATE TABLE exercicio (
  id bigint NOT NULL,
  corpo text NOT NULL,
  limite smallint,
  -- Chave primária do conteúdo
  CONSTRAINT pk_exercicio PRIMARY KEY(id),
  -- Chave estrangeira para conteúdo
  CONSTRAINT fk_exercicio FOREIGN KEY(id) REFERENCES conteudo(id) ON DELETE CASCADE,
  -- Check para garantir que o limite seja nulo ou positivo
  CONSTRAINT ck_limite CHECK(
    limite is NULL
    OR limite > 0
  )
);

--------------------------
-- Relação: Alternativa --
--------------------------
-- Sequência para gerar IDs de alternativa
CREATE SEQUENCE alternativa_id_seq START 1 AS bigint;

-- Tabela de alternativa
CREATE TABLE alternativa (
  id bigint NOT NULL DEFAULT nextval('alternativa_id_seq'),
  corpo text NOT NULL,
  explicacao text,
  correta bool NOT NULL,
  exercicio bigint NOT NULL,
  -- Chave primária autogerada
  CONSTRAINT pk_alternativa PRIMARY KEY(id),
  -- Chave estrangeira para exercício
  CONSTRAINT fk_alternativa FOREIGN KEY(exercicio) REFERENCES exercicio(id) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER SEQUENCE alternativa_id_seq OWNED BY alternativa.id;

-------------------------
-- Relação: Comentário --
-------------------------
-- Sequência para gerar IDs de comentário
CREATE SEQUENCE comentario_id_seq START 1 AS bigint;

-- Tabela de comentário
CREATE TABLE comentario (
  id bigint NOT NULL DEFAULT nextval('comentario_id_seq'),
  autor varchar(16) NOT NULL,
  conteudo bigint NOT NULL,
  horario timestamp NOT NULL,
  corpo text NOT NULL,
  visivel bool NOT NULL DEFAULT true,
  responde bigint DEFAULT NULL,
  -- Chave primária autogerada
  CONSTRAINT pk_comentario PRIMARY KEY(id),
  -- Chave candidata para autor, conteúdo e horário
  CONSTRAINT uk_comentario_autor_conteudo_horario UNIQUE(autor, conteudo, horario),
  -- Chave estrangeira para usuário
  CONSTRAINT fk_comentario_autor FOREIGN KEY(autor) REFERENCES usuario(nome) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Chave estrangeira para conteúdo
  CONSTRAINT fk_comentario_conteudo FOREIGN KEY(conteudo) REFERENCES conteudo(id) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Chave estrangeira para comentário (resposta)
  CONSTRAINT fk_comentario_resposta FOREIGN KEY(responde) REFERENCES comentario(id) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER SEQUENCE comentario_id_seq OWNED BY comentario.id;

---------------------
-- Relação: Report --
---------------------
CREATE TABLE report(
  reporter varchar(16) NOT NULL,
  comentario bigint NOT NULL,
  horario timestamp NOT NULL DEFAULT now(),
  motivo text NOT NULL,
  verificado bool NOT NULL DEFAULT false,
  -- Chave primária composta por reporter, comentário e horário
  CONSTRAINT pk_report PRIMARY KEY(reporter, comentario, horario),
  -- Chave estrangeira para usuário
  CONSTRAINT fk_report_reporter FOREIGN KEY(reporter) REFERENCES usuario(nome) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Chave estrangeira para comentário
  CONSTRAINT fk_report_comentario FOREIGN KEY(comentario) REFERENCES comentario(id) ON DELETE CASCADE ON UPDATE CASCADE
);

------------------------------
-- Relação: EventoProgresso --
------------------------------
-- Sequência para gerar IDs de evento
CREATE SEQUENCE eventoprogresso_id_seq START 1 AS bigint;

-- Tabela de evento
CREATE TABLE eventoprogresso(
  id bigint NOT NULL DEFAULT nextval('eventoprogresso_id_seq'),
  usuario varchar(16) NOT NULL,
  conteudo bigint NOT NULL,
  horario timestamp NOT NULL,
  -- Chave primária autogerada
  CONSTRAINT pk_eventoprogresso PRIMARY KEY(id),
  -- Chave candidata para usuário, conteúdo e horário
  CONSTRAINT uk_eventoprogresso_usuario_conteudo_horario UNIQUE(usuario, conteudo, horario),
  -- Chave estrangeira para usuário
  CONSTRAINT fk_evento_usuario FOREIGN KEY(usuario) REFERENCES usuario(nome) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Chave estrangeira para conteúdo
  CONSTRAINT fk_evento_conteudo FOREIGN KEY(conteudo) REFERENCES conteudo(id) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER SEQUENCE eventoprogresso_id_seq OWNED BY eventoprogresso.id;

-------------------------------------
-- Relação: SeleçãoEventoProgresso --
-------------------------------------
CREATE TABLE selecaoeventoprogresso(
  evento bigint NOT NULL,
  alternativa bigint NOT NULL,
  -- Chave primária composta por evento e alternativa
  CONSTRAINT pk_selecao PRIMARY KEY(evento, alternativa),
  -- Chave estrangeira para evento
  CONSTRAINT fk_selecao_evento FOREIGN KEY(evento) REFERENCES eventoprogresso(id) ON DELETE CASCADE ON UPDATE CASCADE,
  -- Chave estrangeira para alternativa
  CONSTRAINT fk_selecao_alternativa FOREIGN KEY(alternativa) REFERENCES alternativa(id) ON DELETE CASCADE ON UPDATE CASCADE
);
