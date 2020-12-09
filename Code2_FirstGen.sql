select * from(

select distinct spbpers_confid_ind,spriden_id,spriden_first_name,spriden_last_name,spriden_mi,goremal_email_address,

(select stvclas_desc
			   from stvclas
			   where stvclas_code = f_class_calc_fnc(sgbstdn_pidm, sgbstdn_levl_code, #prompt('Enter Term (Ex: 201250)', 'varchar2') #  )) class,


case spraddr_atyp_code 
when 'MA' then 'mailing'
when 'PM' then 'permanent'
else 'not there'
end as atype




,spraddr_street_line1|| ' ' ||spraddr_street_line2|| ' ' ||spraddr_street_line3 As Address,spraddr_city as City,
spraddr_stat_code As state_code,spbpers_lgcy_code,stvlgcy_desc,
row_number() over (partition by spriden_id order by spraddr_atyp_code asc) AS rnum ,sgbstdn_majr_code_1,sgbstdn_majr_code_2,sgbstdn_program_1,sgbstdn_program_2,spbpers_ethn_code

from spriden,goremal,spraddr,spbpers,sfrstcr,stvlgcy,sgbstdn,stvclas
where --exists(select spraddr_atyp_code from spraddr where spraddr_atyp_code ='MA')
 spriden_pidm=sfrstcr_pidm
 and spriden_pidm=sgbstdn_pidm
and spriden_pidm=spraddr_pidm
and spriden_pidm=spbpers_pidm
and spriden_pidm=goremal_pidm
and spriden_change_ind is null
and goremal_emal_code='ESU'
and goremal_status_ind='A'
--and goremal_preferred_ind='Y'
and spbpers_lgcy_code='1'
and spbpers_lgcy_code=stvlgcy_code
and sfrstcr_levl_code in ('UG','UA')
and spraddr_atyp_code in('PM','MA')
and sfrstcr_term_code = #prompt('Enter Term (Ex: 201250)', 'varchar2') #  
and sfrstcr_rsts_code in ('RE','RW','AU')
and spraddr_status_ind is null
and spraddr_seqno=(select max(spraddr_seqno) from spraddr where spraddr_pidm=sfrstcr_pidm)
and sgbstdn_term_code_eff=(select max(sgbstdn_term_code_eff )from sgbstdn where sfrstcr_pidm=sgbstdn_pidm ))
where rnum=1