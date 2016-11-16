CREATE TABLE public.sql_utils(
    field1 CHARACTER VARYING(8),
    field2 CHARACTER VARYING(38),
    field3 DATE
);

INSERT INTO public.sql_utils (field1, field2, field3)
VALUES  ('1', '2', '2016-01-01'),
        ('4', '5', '2016-01-01');
COMMIT;
