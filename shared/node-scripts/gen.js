const child_process = require('child_process');
const fs = require('fs');


// list commit messages from ./ with git
// and generate release notes from them in ./release_notes.md
function generateReleaseNotes(commit_messages, tag = '') {
    const release_notes = [];
    const tag_md = tag ? tag.replace(/\*/g, '\\*') : '';
    const release_notes_header = tag ? `# Release Notes : ${tag_md}` : '# Release Notes';
    const release_notes_footer = '';
    const release_notes_contributors = ['\n# Contributors\n'];
    const release_notes_evo = ['\n# Evolution of the project\n', '| EVO | Date | Contributor | Hash |', '| -------- | ----- | ------------ | ---- |'];
    const release_notes_bug = ['\n# Bugs fixed\n', '| BUGFIX | Date | Contributor | Hash |', '|:--------|:-----|:------------| ---- |'];

	// parse commit messages
    for (const msg of commit_messages) {
        const parts = msg.split('|');
		// if msg is empty, skip
        if (parts[0].length < 1) continue;
        const date = new Date(parts[1]);
        const date_str = `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()}`;
        const lowerMsg = parts[0].toLowerCase();
		// determine release notes
        if (lowerMsg.includes('bug') || lowerMsg.includes('fix') || lowerMsg.includes('correct')) {
            release_notes_bug.push(`| ${parts[0]} | ${date_str} | ${parts[2]} | ${parts[3]} |`);
        } else if (lowerMsg.includes('evo') || lowerMsg.includes('add') || lowerMsg.includes('ajout')) {
            release_notes_evo.push(`| ${parts[0]} | ${date_str} | ${parts[2]} | ${parts[3]} |`);
        } else {
            continue;
        }

        if (!release_notes_contributors.includes(parts[2])) {
            release_notes_contributors.push(parts[2]);
        }
    }
	// generate release notes
    release_notes.push(release_notes_header);
    release_notes.push(release_notes_evo.join('\n'));
    release_notes.push(release_notes_bug.join('\n'));
    release_notes.push(release_notes_contributors.join('  \n'));
    release_notes.push(release_notes_footer);
	// write release notes
    const filename = tag ? `./CHANGELOG-${tag.replace(/[^a-zA-Z0-9]/g, '_')}.md` : './CHANGELOG.md';
    fs.writeFileSync(filename, release_notes.join('\n'));
	// print release notes
    console.log(release_notes.join('\n'));
}

function gen() {
	// get commit messages
    const commit_messages = child_process.execSync('git log --pretty="%s|%ad|%an|%h"').toString().split('\n');
    generateReleaseNotes(commit_messages);
}

function genTag(tag) {
	// get commit messages
    const commit_messages = child_process.execSync(`git log --pretty="%s|%ad|%an|%h" ${tag}`).toString().split('\n');
    generateReleaseNotes(commit_messages, tag);
}

if (process.argv.length > 1 && process.argv[2] != undefined) {
    genTag(process.argv[2]);
} else {
    gen();
}
