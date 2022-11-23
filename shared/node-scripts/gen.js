const child_process = require('child_process')
const fs = require('fs')

// list commit messages from ./ with git
// and generate release notes from them in ./release_notes.md
function gen(){
	// get commit messages
	var commit_messages = child_process.execSync('git log --pretty="%s|%ad|%an|%h"').toString().split('\n')
	//console.log(commit_messages)
	// determine release notes
	var release_notes = []
	var release_notes_header = '# Release Notes\n\n'
	var release_notes_footer = ''
	var release_notes_contributors = ['# Contributors\n']
	var release_notes_evo = ['# Evolution of the project\n', '| EVO | Date | Contributor | Hash |', '| -------- | ----- | ------------ | ---- |']
	var release_notes_bug = ['# Bugs fixed\n', '| BUGFIX | Date | Contributor | Hash |', '|:--------|:-----|:------------| ---- |']
	// parse commit messages
	for(var msg of commit_messages){
		// split message into parts
		var parts = msg.split('|')
		// if msg is empty, skip
		if(parts[0].length < 1) continue
		var date = new Date(parts[1])
		var date_str = date.getDate() + '/' + (date.getMonth()+1) + '/' + date.getFullYear()
		// determine release notes
		// if contains evo (ignore upper case)
		if(parts[0].toLowerCase().indexOf('evo') > -1){
			release_notes_evo.push('| ' + parts[0] + ' | ' + date_str + ' | ' + parts[2] + ' | ' + parts[3] + ' |')
		} else if(parts[0].toLowerCase().indexOf('bug') > -1){
			release_notes_bug.push('| ' + parts[0] + ' | ' + date_str + ' | ' + parts[2] + ' | ' + parts[3] + ' |')
		} else {
			continue
		}
		// determine contributors
		if(!release_notes_contributors.includes(parts[2])){
			release_notes_contributors.push(parts[2])
		}
	}
	// generate release notes
	release_notes.push(release_notes_header)
	release_notes.push(release_notes_evo.join('\n'))
	release_notes.push(release_notes_bug.join('\n'))
	release_notes.push(release_notes_contributors.join('  \n'))
	release_notes.push(release_notes_footer)
	// write release notes
	fs.writeFileSync('./CHANGELOG.md', release_notes.join('\n'))
	// print release notes
	console.log(release_notes.join('\n'))
}

function genTag(tag){
	// get commit messages
	var commit_messages = child_process.execSync('git log --pretty="%s|%ad|%an|%h" --tags="'+tag+'"').toString().split('\n')
	//console.log(commit_messages)
	// determine release notes
	var release_notes = []
	// escape tag for markdown
	var tag_md = tag.replace(/\*/g, '\\*')
	
	var release_notes_header = '# Release Notes : '+tag_md+'\n\n'
	var release_notes_footer = ''
	var release_notes_contributors = ['# Contributors\n']
	var release_notes_evo = ['# Evolution of the project\n', '| EVO | Date | Contributor | Hash |', '| -------- | ----- | ------------ | ---- |']
	var release_notes_bug = ['# Bugs fixed\n', '| BUGFIX | Date | Contributor | Hash |', '|:--------|:-----|:------------| ---- |']
	// parse commit messages
	for(var msg of commit_messages){
		// split message into parts
		var parts = msg.split('|')
		// if msg is empty, skip
		if(parts[0].length < 1) continue
		var date = new Date(parts[1])
		var date_str = date.getDate() + '/' + (date.getMonth()+1) + '/' + date.getFullYear()
		// determine release notes
		// if contains evo (ignore upper case)
		if(parts[0].toLowerCase().indexOf('evo') > -1){
			release_notes_evo.push('| ' + parts[0] + ' | ' + date_str + ' | ' + parts[2] + ' | ' + parts[3] + ' |')
		} else if(parts[0].toLowerCase().indexOf('bug') > -1){
			release_notes_bug.push('| ' + parts[0] + ' | ' + date_str + ' | ' + parts[2] + ' | ' + parts[3] + ' |')
		} else {
			continue
		}
		// determine contributors
		if(!release_notes_contributors.includes(parts[2])){
			release_notes_contributors.push(parts[2])
		}
	}
	// generate release notes
	release_notes.push(release_notes_header)
	release_notes.push(release_notes_evo.join('\n'))
	release_notes.push(release_notes_bug.join('\n'))
	release_notes.push(release_notes_contributors.join('  \n'))
	release_notes.push(release_notes_footer)
	// escape tag for filename
	var tag_escaped = tag.replace(/[^a-zA-Z0-9]/g, '_')
	// write release notes
	fs.writeFileSync('./CHANGELOG-'+tag_escaped+'.md', release_notes.join('\n'))
	// print release notes
	console.log(release_notes.join('\n'))
}

if(process.argv.length < 1){
	gen()
} else if(process.argv[2] != undefined){
	genTag(process.argv[2])
}
