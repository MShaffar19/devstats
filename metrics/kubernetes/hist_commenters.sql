select
  sub.repo_group,
  sub.actor,
  count(distinct sub.id) as comments
from (
  select 'top_commenters,' || coalesce(ecf.repo_group, r.repo_group) as repo_group,
    t.dup_actor_login as actor,
    t.id
  from
    gha_repos r,
    gha_comments t
  left join
    gha_events_commits_files ecf
  on
    ecf.event_id = t.event_id
  where
    {{period:t.created_at}}
    and t.dup_repo_id = r.id
    and t.dup_actor_login not in ('googlebot')
    and t.dup_actor_login not like 'k8s-%'
    and t.dup_actor_login not like '%-bot'
    and t.dup_actor_login not like '%-robot'
  ) sub
where
  sub.repo_group is not null
group by
  sub.actor,
  sub.repo_group
having
  count(distinct sub.id) >= 20
union select 'top_commenters,All' as repo_group,
  dup_actor_login as actor,
  count(distinct id) as comments
from
  gha_comments
where
  {{period:created_at}}
  and dup_actor_login not in ('googlebot')
  and dup_actor_login not like 'k8s-%'
  and dup_actor_login not like '%-bot'
  and dup_actor_login not like '%-robot'
group by
  dup_actor_login
having
  count(distinct id) >= 30
order by
  comments desc,
  repo_group asc,
  actor asc
;
