// sensing agent


/* Initial beliefs and rules */
role_goal(R, G) :- 
	role_mission(R, _, M) & mission_goal(M, G).

can_achieve (G) :-
	.relevant_plans({+!G[scheme(_)]}, LP) & LP \== [].

i_have_plans_for(R) :-
	not (role_goal(R, G) & not can_achieve(G)).

/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start : true <-
	.print("Hello world").

+new_org(OrgName) : true <-
	joinWorkspace(OrgName);
	lookupArtifact(OrgName, OrgArtId);
	focus(OrgArtId);
	.print("Joined organisation ", OrgName).

+group(GroupName,_,GroupArtId) : true <-
	.print("Focusing group ", GroupName);
	lookupArtifact(GroupName, GroupId);
	focus(GroupId);
	!reason_role(temperature_reader, GroupId);
	!reason_role(temperature_manifestor, GroupId).

+scheme(SchemaName,SchemeType,SchemeArtId) : true <-
	.print("Focusing scheme ", SchemeName);
	lookupArtifact(SchemeType, SchemeId);
	focus(SchemeId).

+!reason_role(Role, GroupArtId) : i_have_plans_for(Role) <-
	adoptRole(Role)[artifact_id(GroupArtId)];
	.print("Adopted role ", Role).

+!reason_role(Role, GroupArtId) : true <-
	.print("Unable to adopt role").
/* 
 * Plan for reacting to the addition of the goal !read_temperature
 * Triggering event: addition of goal !read_temperature
 * Context: true (the plan is always applicable)
 * Body: reads the temperature using a weather station artifact and broadcasts the reading
*/
@read_temperature_plan
+!read_temperature : true <-
	.print("I will read the temperature");
	makeArtifact("weatherStation", "tools.WeatherStation", [], WeatherStationId); // creates a weather station artifact
	focus(WeatherStationId); // focuses on the weather station artifact
	readCurrentTemperature(47.42, 9.37, Celcius); // reads the current temperature using the artifact
	.print("Temperature Reading (Celcius): ", Celcius);
	.broadcast(tell, temperature(Celcius)). // broadcasts the temperature reading

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }