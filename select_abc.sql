-- Até 70% dos custos do Total Acumulado = Classe A; (mais importante)
-- De 70% até 90% = Classe B; (importância média)
-- Acima de 90% = Classe C; (menos importante)


set @soma = 0;
set @soma1 = 0;
set @soma2 = 0;
set @soma3 = 0;
set @soma4 = 0;

select p.codigo, pc.valor, p.nome, count(vp.qtde) as qtd_vendida, 
round(sum(vp.qtde * (vp.valor_unitario-vp.valor_desconto)), 2) as valor_total, 
round((select SUM((vp.valor_unitario-vp.valor_desconto) * vp.qtde) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30'), 2) as total,
round((sum(vp.qtde * (vp.valor_unitario-vp.valor_desconto))/(select SUM(vp.qtde * (vp.valor_unitario-vp.valor_desconto)) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30') * 100), 2) as percentual,
(select @soma := @soma + round((sum(vp.qtde * (vp.valor_unitario-vp.valor_desconto))/(select SUM(vp.qtde * (vp.valor_unitario-vp.valor_desconto)) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30') * 100), 2)) as acumulado,
CASE
when (select @soma3 := @soma3 + round(((sum(vp.qtde * (vp.valor_unitario-vp.valor_desconto)))/(select SUM(vp.qtde * (vp.valor_unitario-vp.valor_desconto)) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30') * 100), 2)) > 90.00 then "C"
when (select @soma2 := @soma2 + round(((sum(vp.qtde * (vp.valor_unitario-vp.valor_desconto)))/(select SUM(vp.qtde * (vp.valor_unitario-vp.valor_desconto)) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30') * 100), 2)) > 70.00 then "B" 
when (select @soma1 := @soma1 + round(((sum(vp.qtde * (vp.valor_unitario-vp.valor_desconto)))/(select SUM(vp.qtde * (vp.valor_unitario-vp.valor_desconto)) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30') * 100), 2)) < 71.00 then "A"
when (select @soma4 := @soma4 + round(((sum(vp.qtde * (vp.valor_unitario-vp.valor_desconto)))/(select SUM(vp.qtde * (vp.valor_unitario-vp.valor_desconto)) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30') * 100), 2)) is null then "D"
end
as classificacao
from produto p
left join produto_codigo pc on pc.codigo_produto = p.codigo and codigo_codigo = 1
left join venda_produto vp on vp.codigo_produto = p.codigo
left join recebimento r on vp.codigo_venda=r.codigo_venda
left join view_venda_os v on v.codigo_venda=vp.codigo_venda
where r.data between '2021-11-01' and '2021-11-30' 
and v.status=4 and r.removido=0 and vp.removido=0
group by p.codigo
order by valor_total DESC, p.codigo ASC;
