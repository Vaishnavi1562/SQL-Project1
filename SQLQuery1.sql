select * from project1.dbo.data1;
select * from project1.dbo.data2;

--no. of rows
select count(*) from project1..data1
 
 --dataset for jharkhand and bihar

 select * from project1..data1 where state in ('Jharkhand','Bihar');
 --population of india
 select sum(population) as tot_population from project1..data2;
 --average growth of india
 select state,avg(growth)*100 as Average_growth from project1..data1 group by state;
 --average sex ratio
 select state,round(avg(sex_ratio),0) as avg_sexratio from project1..data1 group by state order by avg_sexratio desc;
 
 -- average literacy rate higher than 90
 select state,round(avg(literacy),0) as avg_literacy_rate from project1..data1
 group by state having round(avg(literacy),0) > 90 order by avg_literacy_rate desc;

 --top3 states showing highest growth rate
 select top 3 state,avg(growth)*100 as Average_growth from project1..data1 group by state order by Average_growth desc;

 --bottom3 states showing highest growth rate
  select top 3 state,avg(growth)*100 as Average_growth from project1..data1 group by state order by Average_growth asc;

  --top and bottom in same table
  drop table if exists.#topstates; --because it will show error if executed
  create table #topstates
  ( state nvarchar(255),
    topstates float
	)
  insert into #topstates 
  select state,avg(growth)*100 as Average_growth from project1..data1 group by state order by Average_growth desc;

  select top 3 * from #topstates order by #topstates.topstates desc

   drop table if exists.#bottomstates; --because it will show error if executed
  create table #bottomstates
  ( state nvarchar(255),
    bottomstates float
	)
  insert into #bottomstates 
  select state,avg(growth)*100 as Average_growth from project1..data1 group by state order by Average_growth desc;

  select top 3 * from #bottomstates order by #bottomstates.bottomstates asc
  --union (colomns no. should be same)

  select * from(
  select top 3 * from #topstates order by #topstates.topstates desc) a
  union
  select * from(
  select top 3 * from #bottomstates order by #bottomstates.bottomstates asc) b;

  --for no. of males and female(district level), we'll be joining both the tables
  select a.district,a.state,a.sex_ratio,b.population from project1..data1 a inner join project1..data2 b on a.district=b.district;
  --when we'll solve 1)f/m=sex_ratio and f+m=population, we'll get m=pop/(sex_ratio+1) and f=pop-pop/(sex_ratio+1)

  select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males, round(c.population*c.sex_ratio/(c.sex_ratio+1),0) females from
    (select a.district,a.state,a.sex_ratio/1000 as sex_ratio,b.population from project1..data1 a inner join project1..data2 b on a.district=b.district) c;
  --for no. of males and female(state level)
  select d.state, sum(d.males) as Males, sum(d.females) Females from
  (select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males, round(c.population*c.sex_ratio/(c.sex_ratio+1),0) females from
    (select a.district,a.state,a.sex_ratio/1000 as sex_ratio,b.population from project1..data1 a inner join project1..data2 b on a.district=b.district) c) d
	group by d.state;

  --total literate people/pop = literacy ratio
  select d.state,sum(d.total_literate_people) statewise_literate_people from
   (select c.district,c.state,round((c.literacy_rate)*c.population,0) as total_literate_people from
    (select a.district,a.state,a.literacy/100 as literacy_rate,b.population from project1..data1 a inner join project1..data2 b on a.district=b.district) c) d
	group by d.state;

  --population in previous census = pop/(1+growth) old pop+old_pop*growth = new_pop
   select c.district,c.state,c.population, round(c.population/(1+growth),0) as pop_previous_census from
    (select a.district,a.state,a.growth,b.population from project1..data1 a inner join project1..data2 b on a.district=b.district) c;
  --population in previous census statewise
  select d.state, sum(d.pop_previous_census) prev_pop_statewise, sum(d.population) curr_pop_statewise from
   (select c.district,c.state,c.population, round(c.population/(1+growth),0) as pop_previous_census from
    (select a.district,a.state,a.growth,b.population from project1..data1 a inner join project1..data2 b on a.district=b.district) c) as d
	group by d.state;

  --total population os India in prev_census
  select g.total_area/g.tot_pre_census_pop as pre_pop_density, g.total_area/g.tot_curr_census_pop as curr_pop_density from
  (select q.*,r.total_area from (
  select '1' as keyy,n.* from
  (select sum(e.prev_pop_statewise) tot_pre_census_pop, sum(e.curr_pop_statewise) tot_curr_census_pop from(
  select d.state, sum(d.pop_previous_census) prev_pop_statewise, sum(d.population) curr_pop_statewise from
   (select c.district,c.state,c.population, round(c.population/(1+growth),0) as pop_previous_census from
    (select a.district,a.state,a.growth,b.population from project1..data1 a inner join project1..data2 b on a.district=b.district) c) as d
	group by d.state) e)n) q inner join(
	
	select '1' as keyy,z.* from
	(select sum(area_km2) as total_area from project1..data2)z) r on q.keyy=r.keyy) g;

	--window
	--top 3 districts from each state with highest literacy rate
	select a.* from
	(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project1..data1) a
	where a.rnk in (1,2,3) order by a.state; 