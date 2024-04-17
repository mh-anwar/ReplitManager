/*
	Date: 2024-04-07
	This program is designed to download all projects from a Replit team. It heavily depends on REPLIT UI not changing.
	To run this program, you must have Node.js installed on your computer and you must install selenium-webdriver using npm.

	This program may break if Replit's UI changes
*/

const { Builder, By, Browser, until } = require('selenium-webdriver');
// Get user to enter their email and password
// Ask user for input
const readline = require('readline');
const fs = require('fs');
const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout,
});

let projectNames = [];
let hrefs;
let email = '';
let password = '';
let timeData = 30;
let teamName = 'ics4u-40-buckland';

function askQuestion(question) {
	return new Promise((resolve, reject) => {
		rl.question(question, (answer) => {
			resolve(answer);
		});
	});
}

async function getUserInput() {
	console.log(
		'\x1b[34m%s\x1b[0m',
		'Information Required to Run Program (not collected):'
	);
	email = await askQuestion('Enter your email: ');
	password = await askQuestion('Enter your password: ');
	console.log(
		'\x1b[31m%s\x1b[0m',
		"\nThis next question is pretty important, if your internet is slow, you'll want to increase the time between project downloads. If your internet is fast, you can decrease the time between project downloads. The default is 30 seconds."
	);
	timeData = await askQuestion(
		'How long should we wait between project downloads (type in a number in seconds): '
	);
	while (isNaN(timeData)) {
		console.log('Please enter a valid number.');
		timeData = await askQuestion(
			'How long should we wait between project downloads (type in a number in seconds): '
		);
	}
	let confirmation = await askQuestion(
		`Are you absolutely sure that you want to timeout for *\x1b[34m${timeData}\x1b[0m* seconds between project downloads? (yes/no): `
	);
	if (confirmation.toLowerCase() !== 'yes') {
		console.log(
			'\x1b[31m%s\x1b[0m',
			'\nPlease restart the program and enter a valid number'
		);
		process.exit(0);
	}
	rl.close();
}

getUserInput().catch((error) => {
	console.error(error); // Fine, we'll throw the error
});

// Wait for the question to be answered
rl.on('close', () => {
	console.log(
		'Using email and password to login: ' + email + ' and ' + password
	);

	(async function () {
		let driver = await new Builder().forBrowser(Browser.CHROME).build();

		await driver.get('https://replit.com/login');

		// Login Process (assumes the user has provided correct username and password)
		// Enter email and password and login
		await driver.findElement({ id: 'username-:r0:' }).sendKeys(email);
		await driver.findElement({ id: 'password-:r6:' }).sendKeys(password);
		await driver.findElement(By.css('[data-cy="log-in-btn"]')).click();

		// Wait for login to complete
		await driver.wait(
			until.elementLocated(By.css('[data-cy="home-text"]')),
			10000
		);

		// Switch to teams page
		await driver.get('https://replit.com/team/' + teamName);

		// Find all <a> elements with href containing the teamName
		const links = await driver.findElements(
			By.xpath(
				'//a[contains(@href, "@' +
					teamName +
					'/") and contains(text(), "Continue working")]'
			)
		);
		console.log('Got all the links to the projects');
		// Extract href attribute values and store them in an array
		hrefs = await Promise.all(
			links.map(async (link) => {
				return await link.getAttribute('href');
			})
		);
		console.log('Getting relevant download elements');
		if (hrefs.length === 0) {
			// Retry if no links are found --> check if
			// Wait for an H4 element to appear, it's text is `Unit 1 - Examples`
			waitForProjectsToLoad(driver);
			hrefs = await Promise.all(
				links.map(async (link) => {
					return await link.getAttribute('href');
				})
			);
		}
		// DEBUGGER: console.log('Links with href containing "@' + teamName + '/":', hrefs);

		// Open all these URL's starting with the first one
		for (let i = 0; i < hrefs.length; i++) {
			// Append `.zip` to the end of each of these to initiate downloading them
			const url = hrefs[i] + '.zip';
			await driver.executeScript(`window.open('${url}', '_blank');`);
			// Wait for 1 minute before downloading next project
			await new Promise((resolve) =>
				setTimeout(resolve, timeData * 1000)
			);
		}

		// Close the browser
		await driver.quit();

		// Process and clean file names to put them into a .projects file
		// Remove https://replit.com/teamname/ from the front of the string, add .zip to the end of the string
		for (let i = 0; i < hrefs.length; i++) {
			const projectNamePart = hrefs[i].replace(
				new RegExp(`^https://replit.com/@${teamName}/`),
				''
			);
			// Append ".zip" to the project name and push it to the array
			projectNames.push(projectNamePart + '.zip');
		}
		// Write all these URL's to a file
		fs.writeFileSync('.projekts', projectNames.join('\n'));
	})();
});

async function waitForProjectsToLoad(driver) {
	await driver.wait(
		until.elementLocated(
			By.css('[data-cy="team-stack-item-title-1.16 Ex8_Hangman"]')
		),
		10000
	);
	const element = await driver.findElement(
		By.css('[data-cy="team-stack-item-title-1.16 Ex8_Hangman"]')
	);
	return element;
}
