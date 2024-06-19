// Создать новые узлы и связи между ними.
MERGE (u:user{
    username: "Yura"
}) -[ownership:owns]-> (r:repository{
    name: 'RepoAnalyzer',
    issues: 10,
    prs: 12,
    forks: 13,
    stars: 333
})

// Вывести все узлы - все репозитории
MATCH (r:repository) RETURN r

// Удаление метки с узлов с атрибутом username.
MATCH (node {attribute: 'username' }) REMOVE node: Label
RETURN node

// Удаление узлов и связей всех найденных сущностей
MATCH(u: user{ name: 'Yura' }) DETACH DELETE u;
// Удаление всех узлов и связей
MATCH(n) DETACH DELETE n

MATCH (u:user{ username: 'Yura' }) RETURN u

MERGE (u:user{ username: 'Yura', comments: 2000 }) -[occupation:works]-> (r:repository{ name: 'RepoAnalyzer', issues: 10, forks: 20, stars: 30 }) return u, r

MATCH (u:user{ username: 'Yura' })
MERGE (u) -[ownership:owns]-> (r:repository{ name: 'STK', issues: 10, forks: 20, stars: 400 }) return u, r

MATCH (u:user { username: 'Yura' }) - [occupation:works] - () DELETE occupation

// Запрос с логическими операторами
MATCH (r:repository) WHERE r.issues = 10 AND r.forks = 20 RETURN r

// Запрос с логическими операторами к узлам и связям между ними
MATCH (r:repository) - [owner:owns] - (u) WHERE r.issues = 10 AND r.forks = 20 RETURN r, u

// Запрос с NOT NULL
MATCH (u:user) WHERE u.comments IS NOT NULL RETURN u

MERGE (u:user{ username: 'Vanya', comments: 230 }) -[occupation:works]-> (r:repository{ name: 'NyandexMail', issues: 230, forks: 120, stars: 3330 }) return u, r

MERGE (u:user{ username: 'Vadim', comments: 430 }) -[occupation:works]-> (r:repository{ name: 'UwuMail', issues: 123, forks: 150, stars: 430 }) return u, r

MATCH (u:user) RETURN u.username, u.comments ORDER BY u.comments DESC

// Создание связи с отношением со свойством
MATCH (boss:user{ username: 'Yura' }), (worker:user{ username: 'Vanya' }) MERGE (boss) -[:pays{ wage: 300 }]-> (worker) RETURN boss, worker

// Фильтрация по направленности связи
// Работает.
MATCH (boss:user{ username: 'Yura' }) -[:pays]-> (worker) RETURN boss, worker
// Перестало работать, так как неверное направление.
MATCH (boss:user{ username: 'Vanya' }) -[:pays]-> (worker) RETURN boss, worker

// Создание связи с отношением со свойством
MATCH (boss:user{ usename: 'Yura' }) -[working:pays] -> (worker) WHERE working.wage = 300 RETURN boss, worker
MATCH (boss:user{ username: 'Yura' }) MERGE (boss) -[payment:pays{ wage: 500 }]-> (worker:user{ username: 'Pavel', comments: 1322 }) RETURN boss, worker
MATCH (boss:user{ usename: 'Yura' }) -[payment:pays] -> (worker) WHERE payment.wage IS NOT NULL RETURN boss, worker
