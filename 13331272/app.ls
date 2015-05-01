root = exports ? @

root.People = new Mongo.Collection 'People'
root.Issue = new Mongo.Collection 'Issue'
root.Submission = new Mongo.Collection 'Submission'
