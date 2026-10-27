// 1. PEL·LÍCULES (films.csv)
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/planetacomputer/starwars-full/refs/heads/main/films.csv"
AS row
UNWIND split(row.producer, ",") AS producer
MERGE (f:Film {name: trim(row.title), opening: row.opening_crawl})
MERGE (d:Person {name: trim(row.director)})
MERGE (f)-[:DIRECTED_BY]->(d)
MERGE (p:Person {name: trim(producer)})
MERGE (p)<-[:PRODUCED_BY]-(f);


// 2. PERSONATGES (characters.csv)
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/planetacomputer/starwars-full/refs/heads/main/characters.csv"
AS row
MERGE (c:Character {name: trim(row.name)})
FOREACH (it IN CASE
    WHEN trim(row.homeworld) IN ["None", "Unknown", ""]
    THEN []
    ELSE [trim(row.homeworld)]
END |
    MERGE (p:Planet {name: it})
    MERGE (c)-[:IS_HOMEWORLD]->(p)
)
FOREACH (it IN CASE
    WHEN trim(row.species) IN ["Unknown", "None", ""]
    THEN []
    ELSE [trim(row.species)]
END |
    MERGE (s:Species {name: it})
    MERGE (c)-[:IS_OF_SPECIE]->(s)
)
SET
    c.gender = CASE
        WHEN row.gender = "None" OR row.gender = "" THEN null
        ELSE row.gender
    END,
    c.height = toFloat(row.height),
    c.weight = toFloat(row.weight),
    c.born = toInteger(row.year_born),
    c.died = toInteger(row.year_died),
    c.descripcion = row.description;


// 3. PLANETES (planets.csv)
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/planetacomputer/starwars-full/refs/heads/main/planets.csv"
AS row
UNWIND split(row.terrain, ',') AS terrain
UNWIND split(row.climate, ',') AS climate
UNWIND split(row.residents, ',') AS residents
UNWIND split(row.films, ',') AS film
MERGE (p:Planet {name: trim(row.name)})
MERGE (t:Terrain {name: trim(terrain)})
MERGE (c:Climate {name: trim(climate)})
MERGE (f:Film {name: trim(film)})
MERGE (p)-[:HAS_TERRAIN]->(t)
MERGE (p)-[:HAS_CLIMATE]->(c)
MERGE (p)-[:APPEARS_IN]->(f)
SET
    p.diameter = toInteger(row.diameter),
    p.rotation_period = toInteger(row.rotation_period),
    p.orbital_period = toInteger(row.orbital_period),
    p.gravity = toFloat(replace(row.gravity, "standard", "")),
    p.population = toFloat(row.population),
    p.surface_water = toInteger(row.surface_water);


// 4. ORGANITZACIONS (organizations.csv)
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/planetacomputer/starwars-full/refs/heads/main/organizations.csv"
AS row
MERGE (o:Organization {name: trim(row.name)})
FOREACH (it IN CASE
    WHEN trim(row.leader) IN ["None", "Unknown", ""] THEN []
    ELSE split(row.leader, ",")
END |
    MERGE (c:Character {name: trim(it)})
    MERGE (c)-[:LEADER_OF]->(o)
)
FOREACH (it IN CASE
    WHEN trim(row.members) IN ["None", "Unknown", ""] THEN []
    ELSE split(row.members, ",")
END |
    MERGE (:Character {name: trim(it)})
)
FOREACH (it IN CASE
    WHEN trim(row.films) IN ["None", "Unknown", ""] THEN []
    ELSE split(row.films, ",")
END |
    MERGE (f:Film {name: trim(it)})
    MERGE (o)-[:APPEARS_IN]->(f)
)
FOREACH (it IN CASE
    WHEN trim(row.afiliation) IN ["None", "Unknown", ""] THEN []
    ELSE [trim(row.afiliation)]
END |
    MERGE (a:Affiliation {name: it})
    MERGE (o)-[:BELONGS_TO]->(a)
)
SET
    o.founded = toInteger(row.founded),
    o.dissolved = toInteger(row.dissolved),
    o.description = row.description;


// 5. ESPÈCIES (species.csv)
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/planetacomputer/starwars-full/refs/heads/main/species.csv"
AS row
MERGE (s:Species {name: trim(row.name)})
FOREACH (it IN CASE
    WHEN trim(row.classification) IN ["Unknown", "None", ""] THEN []
    ELSE [trim(row.classification)]
END |
    MERGE (g:Genus {name: it})
    MERGE (s)-[:BELONGS_TO]->(g)
)
FOREACH (it IN CASE
    WHEN trim(row.homeworld) IN ["Unknown", "Various", "None", ""] THEN []
    ELSE [trim(row.homeworld)]
END |
    MERGE (p:Planet {name: it})
    MERGE (s)-[:IS_HOMEWORLD]->(p)
)
SET
    s.designation = row.designation,
    s.average_height = toFloat(row.average_height),
    s.average_lifespan = toInteger(row.average_lifespan),
    s.language = row.language;


// 6. VEHICLES (vehicles.csv)
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/planetacomputer/starwars-full/refs/heads/main/vehicles.csv"
AS row
MERGE (v:Vehicle {name: trim(row.name)})
MERGE (m:Manufacturer {name: trim(row.manufacturer)})
MERGE (cl:Class {name: trim(row.vehicle_class)})
MERGE (v)-[:MANUFACTURED_BY]->(m)
MERGE (v)-[:VEHICLE_CLASS]->(cl)
FOREACH (it IN CASE
    WHEN trim(row.pilots) IN ["None", "Unknown", ""] THEN []
    ELSE split(row.pilots, ",")
END |
    MERGE (p:Character {name: trim(it)})
    MERGE (p)-[:PILOTED]->(v)
)
FOREACH (it IN CASE
    WHEN trim(row.films) IN ["None", "Unknown", ""] THEN []
    ELSE split(row.films, ",")
END |
    MERGE (f:Film {name: trim(it)})
    MERGE (v)-[:APPEARS_IN]->(f)
)
SET
    v.model = row.model,
    v.cost = toFloat(row.cost_in_credits),
    v.length = toFloat(row.length),
    v.max_speed = toFloat(row.max_atmosphering_speed),
    v.crew = toInteger(row.crew),
    v.passengers = toInteger(row.passengers),
    v.cargo_capacity = toFloat(row.cargo_capacity);


// 7. CITES (quotes.csv)
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/planetacomputer/starwars-full/refs/heads/main/quotes.csv"
AS row
MERGE (q:Quote {text: trim(row.quote)})
MERGE (c:Character {name: trim(row.character_name)})
MERGE (f:Film {name: trim(row.source)})
MERGE (q)-[:QUOTE_FROM]->(c)
MERGE (q)-[:SAID_IN]->(f);


// 8. NAUS ESPACIALS (starships.csv)
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/planetacomputer/starwars-full/refs/heads/main/starships.csv"
AS row
MERGE (s:Starship {name: trim(row.name)})
MERGE (m:Manufacturer {name: trim(row.manufacturer)})
MERGE (cl:Class {name: trim(row.starship_class)})
MERGE (s)-[:MANUFACTURED_BY]->(m)
MERGE (s)-[:STARSHIP_CLASS]->(cl)
FOREACH (it IN CASE
    WHEN trim(row.pilots) IN ["None", "Unknown", ""] THEN []
    ELSE split(row.pilots, ",")
END |
    MERGE (p:Character {name: trim(it)})
    MERGE (p)-[:PILOTED]->(s)
)
FOREACH (it IN CASE
    WHEN trim(row.films) IN ["None", "Unknown", ""] THEN []
    ELSE split(row.films, ",")
END |
    MERGE (f:Film {name: trim(it)})
    MERGE (s)-[:APPEARS_IN]->(f)
)
SET
    s.model = row.model,
    s.cost = toFloat(row.cost_in_credits),
    s.length = toFloat(row.length),
    s.max_speed = toFloat(row.max_atmosphering_speed),
    s.crew = toInteger(row.crew),
    s.passengers = toInteger(row.passengers),
    s.cargo_capacity = toFloat(row.cargo_capacity),
    s.hyperdrive_rating = toFloat(row.hyperdrive_rating);


// 9. ARMES (weapons.csv)
LOAD CSV WITH HEADERS FROM
"https://raw.githubusercontent.com/planetacomputer/starwars-full/refs/heads/main/weapons.csv"
AS row
MERGE (w:Weapon {name: trim(row.name)})
FOREACH (it IN CASE
    WHEN trim(row.manufacturer) IN ["Various", "None", "Unknown", ""] THEN []
    ELSE split(row.manufacturer, ",")
END |
    MERGE (m:Manufacturer {name: trim(it)})
    MERGE (w)-[:MANUFACTURED_BY]->(m)
)
FOREACH (it IN split(row.type, "/") |
    MERGE (wt:WeaponType {name: trim(it)})
    MERGE (w)-[:WEAPON_TYPE]->(wt)
)
FOREACH (it IN CASE
    WHEN trim(row.films) IN ["None", "Unknown", ""] THEN []
    ELSE split(row.films, ",")
END |
    MERGE (f:Film {name: trim(it)})
    MERGE (w)-[:APPEARS_IN]->(f)
)
SET
    w.model = row.model,
    w.cost = toFloat(row.cost_in_credits),
    w.length = toFloat(row.length),
    w.description = row.description;
