select
  concat(inn.type, ';', case inn.sex when 'm' then 'Male' when 'f' then 'Female' end, '`', inn.repo_group, ';rcommitters,rcommits') as name,
  inn.rcommitters,
  inn.rcommits
from (
  select 'sex' as type,
    a.sex,
    'all' as repo_group,
    count(distinct a.name) as rcommitters,
    count(distinct c.sha) as rcommits
  from
    gha_actors a,
    gha_commits c
  where
    c.author_name = a.name
    and a.sex is not null
    and a.sex != ''
    and a.sex_prob >= 0.7
    and c.dup_created_at >= '{{from}}'
    and c.dup_created_at < '{{to}}'
  group by
    a.sex
  union select 'sex' as type,
    a.sex,
    coalesce(ecf.repo_group, r.repo_group) as repo_group,
    count(distinct a.name) as rcommitters,
    count(distinct c.sha) as rcommits
  from
    gha_repos r,
    gha_actors a,
    gha_commits c
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = c.event_id
  where
    r.id = c.dup_repo_id
    and c.author_name = a.name
    and a.sex is not null
    and a.sex != ''
    and a.sex_prob >= 0.7
    and c.dup_created_at >= '{{from}}'
    and c.dup_created_at < '{{to}}'
  group by
    a.sex,
    coalesce(ecf.repo_group, r.repo_group)
) inn
where
  inn.repo_group is not null 
order by
  name
;