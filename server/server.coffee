courses = new Meteor.Collection('Courses')

Meteor.startup ->
	# process.env.MAIL_URL = 'smtp://postmaster%40charlesriverphd.mailgun.org:4db0wwax2ap6@smtp.mailgun.org:587';
  process.env.MAIL_URL = "smtp://charlesriverphd%40gmail.com:595commave@smtp.gmail.com:465/" 
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
  deleteUser: (userId) ->
    Meteor.users.remove(userId) 

  addMember: (usrname, usremail)->
    newuserId = Accounts.createUser {
      username: usrname
      email: usremail
    }
    Accounts.sendEnrollmentEmail(newuserId)

  resendEmail: (userId) ->
    Accounts.sendEnrollmentEmail(userId)
}

Accounts.config {
	forbidClientAccountCreation: true
}

`Accounts.emailTemplates = {
  from: "Charles River PhD <no-reply@charlesriverphd.com>",
  siteName: "Charles River PhD",

  resetPassword: {
    subject: function(user) {
      return "Reset your password" + Accounts.emailTemplates.siteName;
    },
    text: function(user, url) {
      var greeting = (user.profile && user.profile.name) ?
            ("Hello " + user.profile.name + ",") : "Hello,";
      return greeting + "\n"
        + "\n"
        + "To reset your password, simply click the link below.\n"
        + "\n"
        + url + "\n"
        + "\n"
        + "Thanks, charlesriverphd.\n";
    }
  },
  verifyEmail: {
    subject: function(user) {
      return "Welcome to Charles River PhD!";
    },
    text: function(user, url) {
      var greeting = (user.profile && user.profile.name) ?
            ("Hello " + user.profile.name + ",") : "Hello and Welcome!";
      return greeting + "\n"
        + "\n"
        + "Please verify your email by clicking the link below: "
        + "\n"
        + url + "\n"
        + "\n"
        + "Thanks, Charles River PhD.\n"
        + "www.charlesriverphd.com\n";
    }
  },
  enrollAccount: {
    subject: function(user) {
      return "Charles River PhD: an account has been created for you ";
    },
    text: function(user, url) {
      var greeting = (user.username) ?
            ("Hello " + user.username + ",") : "Hello,";
      return greeting + "\n"
        + "\n"
        + "You have been invited to share your course on charlesriverphd.com"
        + "\n"
        + "To start using the service, simply click the link below.\n"
        + "\n"
        + url + "\n"
        + "\n"
        + "Thanks.\n";
    }
  }
};`
