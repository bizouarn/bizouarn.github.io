const child_process = require('child_process');
const fs = require('fs');

// list commit messages from ./ with git
// and generate release notes from them in ./release_notes.md
function gen(){
    // get commit messages
    var commit_messages = child_process.execSync('git log --pretty="%s|%ad|%an"').toString().split('\n');
    //console.log(commit_messages);
    // determine release notes
    var release_notes = [];
    var release_notes_header = '# Release Notes\n\n';
    var release_notes_footer = '';
    var release_notes_contributors = ['# Contributors\n'];
    var release_notes_evo = ['# Evolution of the project\n', '| Version | Date | Contributor |\n', '|:--------|:-----|:------------|\n'];
    var release_notes_bug = ['# Bugs fixed\n', '| Version | Date | Contributor |\n', '|:--------|:-----|:------------|\n'];
    // parse commit messages
    for(var msg of commit_messages){
        // split message into parts
        var parts = msg.split('|');
        // if msg is empty, skip
        if(parts[0].length < 1) continue;
        // determine release notes
        if(msg.includes('evo')){
            release_notes_evo.push('| ' + parts[0] + ' | ' + parts[1] + ' | ' + parts[2] + ' |\n');
        } else if(msg.includes('bug')){
            release_notes_bug.push('| ' + parts[0] + ' | ' + parts[1] + ' | ' + parts[2] + ' |\n');
        }
        // determine contributors
        if(!release_notes_contributors.includes(parts[2])){
            release_notes_contributors.push(parts[2]);
        }
    }
    // generate release notes
    release_notes.push(release_notes_header);
    release_notes.push(release_notes_evo.join('\n'));
    release_notes.push(release_notes_bug.join('\n'));
    release_notes.push(release_notes_contributors.join(' \n'));
    release_notes.push(release_notes_footer);
    // write release notes
    fs.writeFileSync('./CHABGELOG.md', release_notes.join('\n'));
    // print release notes
    console.log(release_notes.join('\n'));
}
gen();