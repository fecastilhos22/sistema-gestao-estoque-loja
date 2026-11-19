create table if not exists vendas (
  id bigint generated always as identity primary key,
  data date not null default current_date,
  forma_pagamento text not null
    check (forma_pagamento in
      ('dinheiro', 'pix', 'debito', 'credito_vista', 'credito_parcelado')),
  num_parcelas integer,
  valor_total numeric(10,2) not null,
  status text not null default 'fechada'
);

create table if not exists itens_venda (
  id bigint generated always as identity primary key,
  venda_id bigint not null references vendas(id) on delete cascade,
  produto_id bigint not null references produtos(id),
  valor_unitario numeric(10,2) not null
);

alter table vendas enable row level security;
alter table itens_venda enable row level security;