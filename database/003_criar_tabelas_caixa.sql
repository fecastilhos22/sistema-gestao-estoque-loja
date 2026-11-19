create table if not exists caixa_dia (
  id bigint generated always as identity primary key,
  data date not null unique default current_date,
  valor_abertura numeric(10,2) not null,
  valor_fechamento_conferido numeric(10,2),
  status text not null default 'aberto'
    check (status in ('aberto', 'fechado'))
);

create table if not exists caixa_lancamentos (
  id bigint generated always as identity primary key,
  caixa_dia_id bigint not null references caixa_dia(id) on delete cascade,
  tipo text not null check (tipo in ('entrada', 'saida')),
  origem text not null check (origem in ('venda', 'manual')),
  categoria text not null,
  valor numeric(10,2) not null check (valor > 0),
  criado_em timestamptz not null default now()
);

alter table caixa_dia enable row level security;
alter table caixa_lancamentos enable row level security;