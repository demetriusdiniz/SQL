-- P: classe formada por produtos muito populares e que apresentam uma movimentação frequente;
-- Q: produtos de média popularidade e que possuem uma frequência média de transações;
-- R: esse grupo inclui itens de baixa popularidade e que não são movimentados com frequência;


set @soma = 0;
set @soma1 = 0;
set @soma2 = 0;
set @soma3 = 0;
set @soma4 = 0;

select p.codigo, pc.valor, p.nome, floor(sum(vp.qtde)) as qtd_vendida, 
round((select SUM(vp.qtde) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30')) as total,
round((sum(vp.qtde) * 100)/(select SUM(vp.qtde) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30'), 2) as percentual,
(select @soma := @soma + round((sum(vp.qtde) * 100)/(select SUM(vp.qtde) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30'), 2)) as acumulado,
CASE
when (select @soma3 := @soma3 + round(sum((sum(vp.qtde) * 100)/(select SUM(vp.qtde) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30')), 2)) > 50.00 then "R"
when (select @soma2 := @soma2 + round(sum((sum(vp.qtde) * 100)/(select SUM(vp.qtde) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30')), 2)) > 25.00 then "Q" 
when (select @soma1 := @soma1 + round(sum((sum(vp.qtde) * 100)/(select SUM(vp.qtde) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30')), 2)) < 25.00 then "P"
when (select @soma4 := @soma4 + round(sum((sum(vp.qtde) * 100)/(select SUM(vp.qtde) from venda_produto vp left join recebimento r on vp.codigo_venda=r.codigo_venda left join view_venda_os v on v.codigo_venda=r.codigo_venda where v.status=4 and r.removido=0 and vp.removido=0 and r.data between '2021-11-01' and '2021-11-30')), 2)) is null then "0"
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
order by qtd_vendida DESC, p.codigo ASC;
