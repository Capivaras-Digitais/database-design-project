-- Rendimento de um usuário nos exercício, caso não tenha feito nenhum, o rendimento é 0
SELECT
  ep.usuario,
  COALESCE(
    (
      COUNT(
        CASE
          WHEN a.correta = TRUE THEN 1
        END
      ) :: NUMERIC / NULLIF(COUNT(a.correta), 0)
    ),
    0
  ) AS rendimento,
  COUNT(a.id) AS exercicios
FROM
  selecaoeventoprogresso sep
  JOIN alternativa a ON sep.alternativa = a.id
  RIGHT JOIN eventoprogresso ep ON ep.id = sep.evento
GROUP BY
  usuario;

-- Seleciona pessoas cujo tempo gasto em exercícios é maior que a média geral de tempo gasto em exercícios
SELECT
  ep.usuario,
  SUM(duracao) AS tempo
FROM
  eventoprogresso ep
  JOIN conteudo c ON c.id = ep.conteudo
WHERE
  c.tipo = 'E'
GROUP BY
  ep.usuario
HAVING
  SUM(duracao) >= (
    SELECT
      AVG(s.soma)
    FROM
      (
        SELECT
          SUM(duracao) AS soma
        FROM
          eventoprogresso
          JOIN conteudo cc ON cc.id = conteudo
          AND tipo = 'E'
        GROUP BY
          usuario
      ) s
  );

-- Conteúdos com mais reports em comentários
SELECT
  ct.titulo,
  ct.subtitulo,
  ct.tipo,
  count(comentario) AS quantidade
FROM
  report r
  JOIN comentario c ON r.comentario = c.id
  JOIN conteudo ct ON c.conteudo = ct.id
GROUP BY
  ct.titulo,
  ct.subtitulo,
  ct.tipo
ORDER BY
  quantidade DESC;

-- Interseção dos conteúdos vistos que já fora, banidos e por usuários nunca banidos
SELECT
  c.titulo,
  c.tipo
FROM
  (
    (
      SELECT
        conteudo
      FROM
        eventoprogresso ep
        JOIN (
          SELECT
            nome
          FROM
            usuario
          EXCEPT
          SELECT
            banido
          FROM
            banimento
        ) nb ON nb.nome = ep.usuario
    )
    INTERSECT
    (
      SELECT
        conteudo
      FROM
        eventoprogresso ep2
        JOIN (
          SELECT
            nome
          FROM
            usuario u
            JOIN banimento b ON b.banido = u.nome
        ) bn ON bn.nome = ep2.usuario
    )
  ) i
  JOIN conteudo c ON (i.conteudo = c.id)
ORDER BY
  length(c.titulo),
  c.titulo;

-- Divisão relacional: selecionar admins que visualizaram o feedback de todos os usuários que a carolina456 visualizou
SELECT
  DISTINCT administrador
FROM
  visualizacaofeedback vf
WHERE
  NOT EXISTS(
    (
      SELECT
        usuario
      FROM
        visualizacaofeedback vf2
        JOIN feedback f ON f.id = vf2.feedback
      WHERE
        vf2.administrador = 'carolina456'
    )
    EXCEPT
      (
        SELECT
          usuario
        FROM
          visualizacaofeedback vf3
          JOIN feedback f ON f.id = vf3.feedback
        WHERE
          vf.administrador = vf3.administrador
      )
  )
