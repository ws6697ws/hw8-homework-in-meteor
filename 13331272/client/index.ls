Session.setDefault('status', 'login') if not Session.get('status')

Template['main'].helpers {
	login-page:-> Session.get('status') is 'login'
	register-page:->Session.get('status') is 'register'
	is-login:->Session.get('status') is 'online'
	user:->if Session.get('current-user') then Session.get('current-user') else 'none'
	is-teacher:->Session.get('current-user').role is 'teacher'
	current-homework:->Session.get('current-homework')
}

Template['login'].events {
	'click .link-to-regist': (ev, tpl) -> $ '.login-block' .fadeOut !-> Session.set("status", "register")
	'submit form': (ev ,tpl) ->
		ev.prevent-default!
		username = ($ 'input[name=username]').val!
		password = ($ 'input[name=password]').val!
		user = People.findOne {username: username, password:password}
		if  !user
			alert("invalid!")
		else
			Session.set('current-user', user)
			Session.set('status', 'online')
			
}

Template['register'].events {
	'submit form': (ev ,tpl) ->
		ev.prevent-default!
		username = ($ 'input[name=username]').val!
		password = ($ 'input[name=password]').val!
		email = ($ 'input[name=email]').val!
		firstName = ($ 'input[name=firstName]').val!
		lastName = ($ 'input[name=lastName]').val!
		if ($ 'input[name=role]').get(0).checked is true then role = 'student' else role = 'teacher' 
		people = People.findOne {username: username}
		if people then alert "Can't add user: #{name} anymore, cause (s)he's already added." else
			People.insert people = {username, password, email, firstName, lastName, role}
			user = People.findOne {username: username}
			Session.set('current-user', user)
			Session.set('status', 'online')

}



Template['teacher'].events {
	'submit .t-form': (ev ,tpl) ->
		ev.prevent-default!
		title = ($ 'input[name=title]').val!
		deadline = ($ 'input[name=deadline]').val!
		content = ($ 'textarea[name=content]').val!
		user = Session.get('current-user')
		Issue.insert issue = {user, title, deadline, content}
		$ '.modal' .modal 'hide'
	'click .sign-out': (ev, tpl)-> Session.set("status", "login")
}

Template['teacher'].helpers {
	user:->if Session.get('current-user') then Session.get('current-user') else 'none'
	issues:->Issue.find {user: Session.get('current-user')}
}

Template['teacher_item'].helpers {
	isoverdue:(deadline) -> deadline <= (moment new Date()). format 'YYYY-MM-DD HH:mm'
}
Template['student_item'].events {
	'submit .a-form': (ev ,tpl) ->
		ev.prevent-default!
		content = ($ ev.target .find 'textarea').val!
		issueid = $ ev.target .find '.btn-submit' .attr('issue-id')
		score = \none;
		username = Session.get('current-user').username
		latesttime = moment new Date() .format 'YYYY-MM-DD HH:mm'
		submission = Submission.findOne {issueid: issueid, username: username}
		if submission
			Submission.update {_id: submission._id}, $set: {content: content, latesttime: latesttime}
		else
			Submission.insert {issueid: issueid, content: content, score: score, username: username, latesttime: latesttime}
		$ '.modal' .modal 'hide'

}


Template['student'].helpers {
	user:->if Session.get('current-user') then Session.get('current-user') else 'none'
	homeworks:->
		issue-list = Issue.find!.fetch!
		homeworks = []
		for issue in issue-list
			submission = Submission.findOne {username: Session.get('current-user').username, issueid: issue._id}
			if submission
				homeworks.push({issue: issue, submission: submission})
			else
				homeworks.push({issue: issue, submission: 'none'})
		homeworks
}

Template['student'].events {
	'click .sign-out': (ev, tpl)-> Session.set("status", "login")
}

Template['teacher_item'].events {
	'click .grade': (ev, tpl)->
		id = $ ev.target .attr('issue-id')
		Session.set("current-homework", id)
	'submit .edit-form': (ev ,tpl) ->
		ev.prevent-default!
		deadline = ($ ev.target .find 'input[name=newdeadline]').val!
		content = ($ ev.target .find 'textarea[name=newcontent]').val!
		id = ($ ev.target .find 'input[name=id]').val!
		Issue.update {_id: id}, $set: {deadline: deadline, content: content}
		$ '.modal' .modal 'hide'
}

Template['student_item'].helpers {
	isoverdue:(deadline) -> deadline <= (moment new Date()). format 'YYYY-MM-DD HH:mm'
}

Template['grade'].helpers {
	specialworks:->
		specialworks = Submission.find {issueid: Session.get('current-homework')}
		specialworks
}

Template['grade'].events {
	'click .sign-out': (ev, tpl)-> Session.set("status", "login")
}

Template['grade_item'].events {
	'submit .score-form': (ev ,tpl) ->
		ev.prevent-default!
		score = ($ ev.target .find 'input[name=grade]').val!
		username = ($ ev.target .find 'input[name=username]').val!
		submission = Submission.findOne {issueid: Session.get('current-homework'), username: username}
		Submission.update {_id: submission._id}, $set: {score: score}
		$ '.modal' .modal 'hide'
}