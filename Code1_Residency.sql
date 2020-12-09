--enrolled students
SELECT tbl1.*,cnty.stvcnty_desc
FROM  (
        SELECT spriden_id
            , F_ESU_GET_SPBPERS(SPRIDEN_PIDM, 'SPBPERS_PREF_FIRST_NAME') "Preferred Name"
            , spriden_last_name
            , spriden_first_name
            , spriden_mi
            , f_esu_sgbstdn_fields(spriden_pidm, #prompt('Enter Starting Term Code', 'varchar2') #, 'RESIDENCY') resd
            , f_esu_sgbstdn_fields(spriden_pidm, #prompt('Enter Starting Term Code', 'varchar2') #, 'LEVEL') levl
            , spraddr_atyp_code     AS atype
            , spraddr_street_line1  AS street1
            , spraddr_street_line2  AS street2
            , spraddr_street_line3  AS street3
            , spraddr_city          AS city
            , spraddr_stat_code     AS state
            , spraddr_zip           AS zip
            , spraddr_cnty_code     AS county
            , category              AS category
            , #prompt('Enter Starting Term Code', 'varchar2') # term
            , 'Currently Enrolled' STATUS
        FROM spriden                iden

        LEFT OUTER JOIN (
                            SELECT spraddr_pidm, spraddr_atyp_code, spraddr_street_line1, spraddr_street_line2, spraddr_street_line3, spraddr_city, spraddr_stat_code, spraddr_zip, spraddr_cnty_code, category, spraddr_to_date
                            FROM (
                                    SELECT DISTINCT spraddr_pidm, spraddr_atyp_code, spraddr_street_line1, spraddr_street_line2, spraddr_street_line3, spraddr_city, spraddr_stat_code, spraddr_zip, spraddr_cnty_code, category, spraddr_to_date, ROW_NUMBER() OVER (PARTITION BY spraddr_pidm ORDER BY spraddr_to_date DESC NULLS FIRST, spraddr_atyp_code DESC ) AS rnum
                                    FROM (
                                            SELECT DISTINCT spraddr_pidm, spraddr_atyp_code, spraddr_street_line1, spraddr_street_line2, spraddr_street_line3, spraddr_city, spraddr_stat_code, spraddr_zip, spraddr_cnty_code, spraddr_to_date
                                                , (CASE 
													WHEN spraddr_atyp_code  IN ('PM', 'MA') AND spraddr_cnty_code IN ('MO003','MO013','MO021','MO025','MO037','MO047','MO049','MO063','MO095','MO101','MO107','MO117','MO165','MO177') THEN 'CorkyPlus'
                                                    WHEN  spraddr_atyp_code  IN ('PM', 'MA') AND spraddr_cnty_code IN ('OK017','OK021','OK037','OK047','OK051','OK053','OK071','OK073','OK081','OK083','OK087','OK101','OK103'
                                                                                                                                                    ,'OK105','OK107','OK109','OK111','OK113','OK117','OK119','OK125','OK131','OK143','OK145','OK147'
                                                                                                                                                    ) THEN 'HornetNation'
                                                    ELSE 'Address Change'
                                                END) AS "CATEGORY"

                                            FROM spraddr WHERE spraddr_atyp_code  IN ('PM', 'MA')
			AND spraddr_status_ind is null
                                        ) y
                                ) x WHERE rnum = 1
                        )           addr
          ON iden.spriden_pidm            = addr.spraddr_pidm
         AND UPPER(TRIM(spraddr_atyp_code)) IN ('PM', 'MA')
         AND UPPER(TRIM(spraddr_cnty_code)) IN ('MO003','MO013','MO021','MO025','MO037','MO047','MO049','MO063','MO095','MO101','MO107','MO117','MO165','MO177','OK017','OK029','OK037','OK047','OK051'
                                               ,'OK053','OK071','OK073','OK081','OK083','OK087','OK101','OK103','OK105','OK107','OK109','OK111','OK113','OK117','OK119','OK125','OK131','OK143','OK145','OK147'
                                               )
         AND ( spraddr_to_date IS NULL OR spraddr_to_date < SYSDATE )

        WHERE spriden_change_ind IS NULL
          AND spriden_pidm IN (SELECT sfrstcr_pidm FROM sfrstcr WHERE sfrstcr_term_code = #prompt('Enter Starting Term Code', 'varchar2') # AND sfrstcr_rsts_code IN ('AU', 'RE', 'RW'))
    )   tbl1

LEFT JOIN stvcnty  cnty
ON UPPER(TRIM(tbl1.county)) = UPPER(TRIM(cnty.stvcnty_code))