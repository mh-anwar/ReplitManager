const { Builder, By, Browser, until } = require('selenium-webdriver');
// Get user to enter their email and password
// Ask user for input
const readline = require('readline');
const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout,
});

let email = '';
let password = '';
let timeData = 30;

console.log(
	'\x1b[34m%s\x1b[0m',
	'Information Required to Run Program (not collected):'
);
rl.question('Enter your email: ', (emailData) => {
	email = emailData;
	rl.question('Enter your password: ', (passwordData) => {
		password = passwordData;
		console.log(
			'\x1b[31m%s\x1b[0m',
			"\nThis next question is pretty important, if your internet is slow, you'll want to increase the time between project downloads. If your internet is fast, you can decrease the time between project downloads. The default is 30 seconds."
		);
		rl.question(
			'How long should we wait between project downloads (type in a number in seconds): ',
			(timeout) => {
				timeData = timeout;
				// Make sure timeData is an integer, if not end the program
				if (isNaN(timeData)) {
					console.log(
						'\x1b[31m%s\x1b[0m',
						'\nPlease restart the program and enter a valid number'
					);
					process.exit(0);
				}

				rl.question(
					'Are you absolutely sure that you want to timeout for *' +
						timeout +
						'* seconds between project downloads? (yes/no):',
					(yesNo) => {
						if (yesNo === 'yes') {
							rl.close();
						} else {
							// End program
							console.log(
								'\x1b[31m%s\x1b[0m',
								'\nPlease restart the program'
							);
							process.exit(0);
						}
					}
				);
			}
		);
	});
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
		// Enter email and password
		await driver.findElement({ id: 'username-:r0:' }).sendKeys(email);
		await driver.findElement({ id: 'password-:r6:' }).sendKeys(password);
		// Click the login button
		await driver.findElement(By.css('[data-cy="log-in-btn"]')).click();

		// Wait for login to complete
		await driver.wait(
			until.elementLocated(By.css('[data-cy="home-text"]')),
			10000
		);
		// Switch to teams page
		await driver.get('https://replit.com/team/ics4u-40-buckland');

		// Find all <a> elements with href containing '@ics4u-40-buckland/'
		const links = await driver.findElements(
			By.xpath(
				'//a[contains(@href, "@ics4u-40-buckland/") and contains(text(), "Continue working")]'
			)
		);

		// Extract href attribute values and store them in an array
		let hrefs = await Promise.all(
			links.map(async (link) => {
				return await link.getAttribute('href');
			})
		);

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
		console.log('Links with href containing "@ics4u-40-buckland/":', hrefs);

		// Get rid of duplicates in the array

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
