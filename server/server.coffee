courses = new Meteor.Collection('Courses')

Meteor.startup ->
	process.env.MAIL_URL = 'smtp://localhost:587';
	if Meteor.users.find().count() is 0
		options = 
			username: 'admin'
			email: 'stevexyc@bu.edu'
			password: '595commave'
		Accounts.createUser(options)

Meteor.publish('Users',() ->
    Meteor.users.find({},{fields: {'_id':1, 'username': 1, 'emails':1}});
)

Meteor.publish('Courses',() ->
    courses.find({});
)

Meteor.methods {
	addMember: (usrname, usremail)->
		newuserId = Accounts.createUser {
			username: usrname
			email: usremail
		}
		Accounts.sendEnrollmentEmail(newuserId)
}

