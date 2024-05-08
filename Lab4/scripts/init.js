function report(description) {
  print('----- ' + description + ' -----')
}

function get_results(result) {
  print(EJSON.stringify(result, null, 4));
};

// Alternative to: `use ran;`
// db = db.getSiblingDB("ran");
// use ran;
// Create collections.
db.githubUsers.drop();
db.createCollection('githubUsers', { capped: true, autoIndexId: true, size: 371400, max: 10 });

// GitHub Users.
db.githubUsers.insertMany([
  {
    _id: 1,
    username: "vadim",
    email: "email@mail.ru",
    name: "Vadim",
    commits: 220,
    about: {
      work: "Mail.ru",
      job: "Frontend engineer",
    },
  },
  {
    _id: 2,
    username: "sanya",
    email: "email@mail.ru",
    commits: 1220,
    name: "Sanya",
    about: {
      work: "Sber",
      job: "Frontend engineer",
    },
  },
  {
    _id: 3,
    username: "pavel",
    commits: 120,
    email: "pavel@mail.com",
    name: "Pavel",
    about: {
      work: "Bmstu",
      job: "Student",
    },
  },
  {
    _id: 4,
    username: "ivan",
    email: "ivan@mail.ru",
    commits: 40,
    name: "Ivan",
    about: {
      work: "Yandex",
      job: "Разноработчик",
    },
  },
  {
    _id: 5,
    username: "misha",
    commits: 5000,
    email: "misha@mail.ru",
    name: "Misha",
  },
  {
    _id: 6,
    username: "vlad",
    commits: 13,
    email: "vlad@mail.com",
    name: "Vlad",
  },
  {
    _id: 7,
    username: "leha",
    email: "leha-com@mail.ru",
    commits: 400,
    name: "Alexei",
    about: {
      work: "Yandex",
      job: "Джаваскриптизер",
    },
  },
]);

report('Update')
db.githubUsers.update(
  { username: "misha" },
  {
    $set: {
      about: { work: "Bmstu", job: "Starosta" },
      repositories: ["PetMagazine", "Labs", "CourseWork"],
    },
  }
)

report('Print all entries of collection')
db.githubUsers.find().pretty().forEach(get_results)

report('Delete value from array')
db.githubUsers.update(
  { username: "misha" },
  { $pull: { repositories: "CourseWork" } }
)
report('Add value to array')
db.githubUsers.update(
  { username: "misha" },
  { $push: { repositories: "NeuroTrainer" } }
)
db.githubUsers.find({ username: "misha" }).forEach(get_results)

report('Delete value')
db.githubUsers.update(
  { username: "misha" },
  { $unset: { about: "" } }
)
db.githubUsers.find({ username: "misha" }).forEach(get_results)

report('Changed entire object')
db.githubUsers.replaceOne(
  { username: "vlad" },
  { username: "vladislav", email: "vladislav@mail.ru", name: "Vladislav" }
)
db.githubUsers.find({ username: "vladislav" }).forEach(get_results)


report('Delete entire object')
db.githubUsers.deleteOne(
  { username: "ivan" }
)
db.githubUsers.find().forEach(get_results)

report('Querry entries with "or" operator')
db.githubUsers.find(
  {
    $or: [
      { username: "pavel" },
      { email: "email@mail.ru" },
    ],
  }
).forEach(get_results)

report('Querry entries with "and" operator')
db.githubUsers.find(
  {
    $and: [
      { username: "sanya" },
      { email: "email@mail.ru" },
    ],
  }
).forEach(get_results)

report('Querry entries with projection')
db.githubUsers.find(
  { email: "email@mail.ru" },
  { _id: false, username: true },
).forEach(get_results)

report('Sorting')
db.githubUsers.find()
  .sort({ username: 1 })
  .forEach(get_results)

report('Distinct')
db.githubUsers.distinct("email")
  .forEach(get_results)

report('Limit result entries count')
db.githubUsers.find().limit(3)
  .forEach(get_results)

report('Testing comparison operators')
db.githubUsers.find(
  {
    commits: { $gt: 1000 },
  }
).forEach(get_results)

report('Group by about.work')
db.githubUsers.aggregate(
  {
    $group: {
      _id: "$about.work",
      num_of_workers: { $count: {} },
      commits_per_company: { $sum: "$commits" },
    }
  }
).forEach(get_results)

report('Exists')
db.githubUsers.find(
  {
    "about": { $exists: false },
  }
).forEach(get_results)

// Доп задания.
report('Доп. 1. Пользователи, где имейл колнчается.com и работают в МГТУ')
db.githubUsers.find(
  {
    $and: [
      { "email": { $regex: /.*\.com/ } },
      { "about.work": "Bmstu" },
    ]
  }
).forEach(get_results)

report('Доп. 2. Среднее число коммитов у пользователей из Яндекса')
db.githubUsers.aggregate(
  [
    {
      $match: { "about.work": "Yandex" },
    },
    {
      $group: {
        _id: "$about.work",
        commits_avg: { $avg: "$commits" },
      },
    },
  ]
).forEach(get_results)

report('Доп. 3. Пользователь, у которого в репозитории есть Labs')
db.githubUsers.find({ "repositories": { $in: ["Labs"] } })
  .forEach(get_results)

report("Index")
db.githubIssues.drop();
db.createCollection('githubIssues');

db.githubIssues.createIndex({ 'tag': 1 })
db.githubIssues.dropIndex('tag_1')
db.githubIssues.getIndexes()

report('Создание связанных коллекций')
// GitHub Issues.
db.githubIssues.insertMany([
  {
    title: 'Nasty program bug',
    tag: "bug",
    comment: 'I have found a bug!',
    // author: new DBRef('githubUsers', 1),
    author: { $ref: 'githubUsers', $id: 1 }
  },
  {
    title: 'New feature',
    tag: "feature",
    comment: "Let's add a new feature!",
    author: new DBRef('githubUsers', 2),
    // author: { $ref: 'githubUsers', $id: 1, id: 1 }
  },
  {
    title: 'Unicode issue',
    tag: "bug",
    comment: "Chisene character don't work!",
    // author: new DBRef('githubUsers', 4),
    author: { $ref: 'githubUsers', $id: 4 }
  },
])

db.githubIssues.find()
  .forEach(get_results)
// db.githubUsers.find({ _id: db.githubIssues.findOne({ title: 'New feature' }).author.$id })
//   .forEach(get_results)

db.githubUsers.find().forEach(get_results)
var userRef = db.githubIssues.findOne({ title: 'New feature' }).author
print(userRef)
// db.githubUsers.find({ _id: db.githubIssues.findOne({ title: 'New feature' }).author.$id })
//   .forEach(get_results)

db.githubUsers.find({ "_id": userRef.$id })
  .forEach(get_results)
