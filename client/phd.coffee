`courses = new Meteor.Collection('Courses')`
LoadFirst = Meteor.subscribe("Users")
Meteor.subscribe("Courses")

Deps.autorun () ->
	if LoadFirst.ready()
		if Meteor.user()
			$('#myCourse').show()
			$('#addMyCourse').show()
		else
			$('#myCourse').hide()
			$('#addMyCourse').hide()

getNowSem = () ->
	nowm = new Date().getMonth();
	if nowm >= 0 and nowm < 5 then 0
	else if nowm >= 5 and nowm < 8 then	1
	else 2

getNowYear = () ->
	new Date().getFullYear()

getUpcomingSem = () ->
	arrblah = []
	`for(var n=nowSem;n<=2;n++) {
		arrblah.push([n,nowYear])
	}`
	for theSem in [0,1,2]
		arrblah.push [theSem, (nowYear + 1)]
	`for(var n=0;n<=nowSem;n++){
		arrblah.push([n,nowYear +2])
	}`
	arrblah;

@nowSem = getNowSem()
@nowYear = getNowYear()
@upcomingSem = getUpcomingSem()
currentSem = null
currentId = null
@listedArr = [];

Template.nav.adminUp = () ->
	if LoadFirst.ready()
		if Meteor.user()
			if isAdmin(Meteor.userId()) then true
		else false


Template.nav.events {
	'click #allCourse': (e,t) ->
		$('#newCourse').hide()
		$('#courseList').hide()
		$('#myCourseList').hide()
		$('#mainList').fadeIn()
		$('#myCourse').css('color','#999999')
		$('#allCourse').css('color','#efefef')
		$('#addMyCourse').css('color','#999999')
		$('#zCourse').css('color','#999999')
	'click #addMyCourse': (e,t) ->
		$('#mainList').hide()
		$('#courseList').hide()
		$('#myCourseList').hide()
		$('#newCourse').fadeIn()
		$('#myCourse').css('color','#999999')
		$('#allCourse').css('color','#999999')
		$('#addMyCourse').css('color','#efefef')
		$('#zCourse').css('color','#999999')
	'click #myCourse': (e,t) ->
		$('#mainList').hide()
		$('#courseList').hide()
		$('#newCourse').hide()
		$('#myCourseList').fadeIn()
		$('#myCourse').css('color','#efefef')
		$('#allCourse').css('color','#999999')
		$('#addMyCourse').css('color','#999999')
		$('#zCourse').css('color','#999999')
	'click #zCourse': (e,t) ->
		$('#newCourse').hide()
		$('#myCourseList').hide()
		$('#mainList').hide()
		$('#courseList').fadeIn()
		$('#myCourse').css('color','#999999')
		$('#allCourse').css('color','#999999')
		$('#addMyCourse').css('color','#999999')
		$('#zCourse').css('color','#efefef')
	'click #addMember': (e,t) ->
		$('#myModal').modal('show');
}
Template.mainList.upcomingSem = () ->
	upcomingSem

Template.mainList.semesterNamex = () ->
	if this[0] is 0 then 'Spring ' + this[1]
	else if this[0] is 1 then 'Summer ' + this[1]
	else if this[0] is 2 then 'Fall ' + this[1]
	else 'Never'

Template.mainList.coursex = () ->
	zSem = this[0]
	zYear = this[1]
	zYear1 = parseInt(zYear) - 1
	zYear2 = parseInt(zYear) - 2
	zYear3 = parseInt(zYear) - 3
	courses.find({$or: [
		{nextYear:zYear, nextSem:zSem}, 
		{nextSem:zSem, courseFreq: "Every Year", nextYear: zYear1}, 
		{nextSem:zSem, courseFreq: "Every Year", nextYear: zYear2},
		{nextSem:zSem, courseFreq: "Every Year", nextYear: zYear3},
		{nextSem:zSem, courseFreq: "Every Other Year", nextYear: zYear2}
	]})

Template.mainList.courseFIT = () ->
	console.log this.nextYear
	console.log upcomingSem
	true

Template.mainList.course = () ->
	# courses.find({nextTaught:true, nextYear:{$gte:nowYear}, nextSem:{$gte:nowSem}},{sort:{nextYear:1, nextSem:1, courseName:1}})
	courses.find({nextTaught:true, nextYear:{$gte:nowYear}},{sort:{nextYear:1, nextSem:1, courseName:1}})

Template.mainList.zId = () ->
	randomID = this._id + Math.floor(Math.random()*100)
	currentId = randomID

Template.mainList.oId = () ->
	currentId

Template.mainList.syllabusLink1 = () ->
	if this.syllabusLink.length > 7 then true

Template.mainList.prevCourse = () ->
	courses.find({$or: [{nextTaught:false},{nextYear:{$lte:nowYear}}]},{sort:{courseName:1}})

Template.mainList.rightSem = () ->
	if this.nextYear > nowYear and this.nextYear < (nowYear + 3) then true
	else if this.nextYear == nowYear and this.nextSem >= nowSem then true
	else false

Template.mainList.prevRightSem = () ->
	if this.nextYear < nowYear then true
	else if this.nextYear == nowYear and this.nextSem < nowSem then true
	else false

Template.mainList.newSem = () ->
	temp = convertNextSem(this.nextSem) + ' ' + this.nextYear
	# console.log temp
	if temp != currentSem and temp not in listedArr
		currentSem = temp
		listedArr.push(temp)
		true
	else false

Template.mainList.SemesterName = () ->
	currentSem

Template.mainList.SemesterAnchor = ()->
	currentSem.replace(/\s+/g, '')

Template.mainList.courseFrequency = () ->
	if this.courseFreq is 'Other'
		this.courseFreqOther
	else 
		this.courseFreq

Template.mainList.events {
	'click #goAnchor': (e,t)->
		goAnchor()
	'keyup #findYear': (e,t)->
		if e.which is 13
			goAnchor()
}

Template.courseList.schoolList = () ->
	['BU Management', 'Harvard HBS', 'MIT Sloan', 'Other']

Template.courseList.schoolCourses = () ->
	tmp = this.toString()
	courses.find({schoolName: tmp}, {sort: {courseName: 1}});

Template.courseList.prevSem1 = ()->
	convertPrevSem(this.prevSem)

Template.courseList.nextSem1 = ()->
	convertPrevSem(this.nextSem)

Template.courseList.syllabusLink1 = ()->
	if this.syllabusLink.length > 7 then true

goAnchor = () ->
	findSeason = $('#findSeason').find(":selected").val()
	findYear = $('#findYear').val().trim()
	location.hash = "#" + findSeason + findYear;

Template.newCourse.events {
	'click #addCourse': (e,t) ->
		courseName = $('#courseName').val()
		courseNumber = $('#courseNumber').val()
		schoolName = $('#schoolName').find(":selected").val()
		instructors = $('#instructors').val()
		courseDescr = $('#courseDescr').val()
		prevSem = parseInt($('#prevSem').find(":selected").val())
		prevYear = parseInt($('#prevYear').val())
		if prevSem isnt 'Never' and prevYear.toString().length is 4
			prevTaught = true 
		else prevTaught = false
		nextSem = parseInt($('#nextSem').find(":selected").val())
		nextYear = parseInt($('#nextYear').val())
		if nextSem isnt 'Never' and nextYear.toString().length is 4
			nextTaught = true 
		else nextTaught = false
		courseFreq = $('#courseFreq').find(":selected").text()
		courseFreqOther = $('#courseFreqOther').val();
		contactInfo = $('#contactInfo').val().trim();
		syllabusLink = $('#syllabus').val().trim()
		creator = Meteor.userId()
		# console.log(courseName + ',' + courseNumber + ',' + schoolName)
		# console.log(instructors + ',' + courseDescr + ',')
		# console.log(prevSem + ',' + prevYear)
		# console.log(nextSem + ',' + nextYear)
		# console.log('prevTaught' + ',' + prevTaught)
		if courseName.length isnt 0 and courseNumber.length isnt 0 and instructors.length isnt 0
			courses.insert {
				creator: creator 
				owners: []
				courseName: courseName
				courseNumber: courseNumber
				schoolName: schoolName
				instructors: instructors
				courseDescr: courseDescr
				prevSem: prevSem
				prevYear: prevYear
				prevTaught: prevTaught
				nextSem: nextSem
				nextYear: nextYear
				nextTaught: nextTaught
				courseFreq: courseFreq
				courseFreqOther: courseFreqOther
				contactInfo: contactInfo
				syllabusLink: syllabusLink
			}
			window.location.reload();
		else 
			$('#courseName').css('border', '2px solid red')
			$('#courseNumber').css('border', '2px solid red')
			$('#instructors').css('border', '2px solid red')
}

Template.myCourse.ownedCourse = ()->
	if LoadFirst.ready() and Meteor.userId()
		if AdminOnly( Meteor.userId() )
			courses.find({},{sort:{nextYear:1, nextSem:1, courseName:1}})
		else 
			courses.find({$or: [{owners: Meteor.userId()}, {creator: Meteor.userId()}]},{sort:{nextYear:1, nextSem:1, courseName:1}})

Template.myCourse.PrevSemSel = (value)->
	if value is this.prevSem then 'selected'

Template.myCourse.NextSemSel = (value)->
	if value is this.nextSem then 'selected'

Template.myCourse.SchoolSel = (value)->
	if value is this.schoolName then 'selected'

Template.myCourse.courseFreqSel = (value)->
	if value is this.courseFreq then 'selected'

Template.myCourse.ownerName = () ->
	if LoadFirst.ready()
		tmp = this.toString()
		Meteor.users.findOne({_id: tmp}).username

Template.myCourse.creatorName = () ->
	if LoadFirst.ready()
		tmp = this.creator.toString()
		Meteor.users.findOne({_id: tmp}).username

Template.myCourse.allUsers = ()->
	Meteor.users.find({_id: {$ne: Meteor.userId()}})
	# Meteor.users.find({})

Template.myCourse.creator = ()->
	true
	# if Meteor.userId() is this.creator then true

Template.myCourse.events {
	'click .updatebtn': (e,t)->
		# console.log this._id
		courseName = $('#my'+ this._id + ' .crsname').val()
		courseNumber = $('#my'+ this._id + ' .crsnumber').val()
		schoolName = $('#my' + this._id + ' .schoolName').find(":selected").val()
		instructors = $('#my'+ this._id + ' .instructors').val()
		courseDescr = $('#my'+ this._id + ' .courseDescr').val()
		prevSem = parseInt($('#my' + this._id + ' .prevSem').find(":selected").val())
		prevYear = parseInt($('#my' + this._id + ' .prevYear').val())
		if prevSem isnt 'Never' and prevYear.toString().length is 4
			prevTaught = true 
		else prevTaught = false
		nextSem = parseInt($('#my' + this._id + ' .nextSem').find(":selected").val())
		nextYear = parseInt($('#my' + this._id + ' .nextYear').val())
		if nextSem isnt 'Never' and nextYear.toString().length is 4
			nextTaught = true 
		else nextTaught = false
		courseFreq = $('#my' + this._id + ' .courseFreq').find(":selected").text()
		courseFreqOther = $('#my' + this._id + ' .courseFreqOther').val();
		contactInfo = $('#my'+ this._id + ' .contactInfo').val().trim();
		syllabusLink = $('#my' + this._id + ' .syllabus').val().trim();
		newOwners = $('#my' + this._id + ' .newOwn').find(":selected").val()
		delOwners = $('#my' + this._id + ' .delOwn').find(":selected").val()
		if courseName.length isnt 0 and courseNumber.length isnt 0 and instructors.length isnt 0
			courses.update({_id:this._id}, {$set: {
				courseName: courseName
				courseNumber: courseNumber,
				schoolName: schoolName,
				instructors: instructors,
				courseDescr: courseDescr,
				prevSem: prevSem,
				prevYear: prevYear
				prevTaught: prevTaught
				nextSem: nextSem
				nextYear: nextYear
				nextTaught: nextTaught
				courseFreq: courseFreq
				courseFreqOther: courseFreqOther
				contactInfo: contactInfo
				syllabusLink: syllabusLink
				}} )

			if newOwners isnt "null"
				# console.log(newOwners)
				courses.update({_id:this._id}, {$addToSet: {owners: newOwners}})

			if delOwners isnt "null"
				courses.update({_id:this._id}, {$pull: {owners: delOwners}})	
	'dblclick .deletebtn': (e,t) ->
		# console.log this._id
		courses.remove({_id: this._id})
}

Template.memberModal.Member = () ->
	Meteor.users.find()

Template.memberModal.events {
	'click #addNewMember': (e,t) ->
		newUserName = $('#newUserName').val()
		newUserEmail = $('#newUserEmail').val()
		# console.log newUserEmail + ', ' + newUserName
		Meteor.call('addMember', newUserName, newUserEmail)
		$('#newUserName').val('')
		$('#newUserEmail').val('')
		$('#myModal').modal('hide')

	'dblclick .DelUser': (e,t) ->
		rfd = this._id 
		console.log rfd
		Meteor.call('deleteUser', rfd)
}

convertPrevSem = (Sem) ->
	if Sem is 0 then 'Spring'
	else if Sem is 1 then 'Summer'
	else if Sem is 2 then 'Fall'
	else 'Never'

convertNextSem = (Sem) ->
	if Sem is 0 then 'Spring'
	else if Sem is 1 then 'Summer'
	else if Sem is 2 then 'Fall'
	else 'Previous Semesters'

isAdmin = (userId) ->
	if LoadFirst.ready()
		tmp = Meteor.users.findOne({_id: userId}).username 
		# console.log tmp
		if tmp is 'admin' or tmp is 'fsuarez' or tmp is 'tsimcoe'
			true
		else false

AdminOnly = (userId) ->
	if LoadFirst.ready()
		tmp = Meteor.users.findOne({_id: userId}).username 
		if tmp is 'admin'
			true
		else false

Accounts.config {
	forbidClientAccountCreation: true
}
Accounts.ui.config({
     passwordSignupFields: 'USERNAME_AND_EMAIL';
});
