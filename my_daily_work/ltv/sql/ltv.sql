SELECT pay_date,
       course_type_detail,
       nvl(l1_sku,'NA') as l1_sku,
       nvl(l1_user_group,'NA') as l1_user_group,
       nvl(l1_goal_channel_type,'NA') as l1_goal_channel_type,
       nvl(go_course_type_detail,'NA') as go_course_type_detail,
       datedif,
       total_gmv,
       user_cnt
FROM htba.test_ltv_course_type_xjh