create table if not exists produtos (
  id bigint generated always as identity primary key,
  codigo text generated always as (lpad(id::text, 4, '0')) stored,
  nome text not null,
  categoria text not null,
  marca text not null,
  fornecedor text not null,
  tamanho text not null,
  cor text not null,
  custo numeric(10,2) not null,
  valor_venda numeric(10,2) not null,
  estoque_minimo integer not null default 0,
  quantidade_atual integer not null default 0,
  status text not null default 'disponivel'
);

alter table produtos enable row level security;