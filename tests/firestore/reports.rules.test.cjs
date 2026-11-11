
const fs = require('node:fs');

const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} = require('firebase/firestore');

async function main() {
  const testEnv = await initializeTestEnvironment({
    projectId: 'demo-rasd',
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules: fs.readFileSync('../../firestore.rules', 'utf8'),
    },
  });

  try {
    // Clear old emulator test data.
    await testEnv.clearFirestore();

    // Create a fictional report without applying Security Rules.

await testEnv.withSecurityRulesDisabled(async (context) => {
  // Create a fictional report owned by Citizen A.
  await setDoc(doc(context.firestore(), 'reports/CMP-001'), {
    citizenId: 'citizenA',
    category: 'Pothole',
    status: 'Pending',
  });

  // Create active citizen profiles for RBAC testing.
  await setDoc(doc(context.firestore(), 'citizens/citizenA'), {
    role: 'citizen',
    accountStatus: 'active',
  });

  await setDoc(doc(context.firestore(), 'citizens/citizenB'), {
    role: 'citizen',
    accountStatus: 'active',
  });
});


    // Simulate two different authenticated citizens.
    const citizenA = testEnv.authenticatedContext('citizenA');
    const citizenB = testEnv.authenticatedContext('citizenB');

    const reportA = doc(citizenA.firestore(), 'reports/CMP-001');
    const reportB = doc(citizenB.firestore(), 'reports/CMP-001');

    // Test 1: Report owner can read their report.
    await assertSucceeds(getDoc(reportA));
    console.log('PASS: Citizen A can read their report');

    // Test 2: Another citizen cannot read the report.
    await assertFails(getDoc(reportB));
    console.log('PASS: Citizen B cannot read Citizen A report');

    // Test 3: Unauthenticated access is denied.
    const guest = testEnv.unauthenticatedContext();

    await assertFails(
      getDoc(doc(guest.firestore(), 'reports/CMP-001')),
    );
    console.log('PASS: Unauthenticated access is denied');

    // Test 4: Citizen A can query only their reports.
    const ownReportsQuery = query(
      collection(citizenA.firestore(), 'reports'),
      where('citizenId', '==', 'citizenA'),
    );

    const ownReports = await assertSucceeds(
      getDocs(ownReportsQuery),
    );

    if (ownReports.size !== 1) {
      throw new Error('Expected exactly one report for Citizen A');
    }

    console.log('PASS: Citizen A can query their own reports');

    // Test 5: Citizen A cannot query Citizen B reports.
    const otherReportsQuery = query(
      collection(citizenA.firestore(), 'reports'),
      where('citizenId', '==', 'citizenB'),
    );

    await assertFails(getDocs(otherReportsQuery));

    console.log('PASS: Citizen A cannot query Citizen B reports');

    // Test 6: Citizen cannot create a report.
    await assertFails(
      setDoc(doc(citizenA.firestore(), 'reports/CMP-NEW'), {
        citizenId: 'citizenA',
        category: 'Pothole',
        status: 'Pending',
      }),
    );
    console.log('PASS: Citizen cannot create reports');

    // Test 7: Citizen cannot update a report.
    await assertFails(
      updateDoc(reportA, {
        status: 'Resolved',
      }),
    );
    console.log('PASS: Citizen cannot update reports');

    // Test 8: Citizen cannot delete a report.
    await assertFails(deleteDoc(reportA));
    console.log('PASS: Citizen cannot delete reports');


    // Test 9: Employee cannot use citizen report ownership access.
    await testEnv.withSecurityRulesDisabled(async (context) => {
      // Create an employee belonging to Amman municipality.
      await setDoc(doc(context.firestore(), 'employees/employeeA'), {
        role: 'employee',
        accountStatus: 'active',
        municipalityId: 'amman',
      });

      // Create a fictional report for testing.
await setDoc(doc(context.firestore(), 'reports/CMP-EMP'), {
  citizenId: 'employeeA',
  municipalityId: 'irbid',
  category: 'Pothole',
  status: 'Pending',
});    });

    const employeeA = testEnv.authenticatedContext('employeeA');

    await assertFails(
      getDoc(doc(employeeA.firestore(), 'reports/CMP-EMP')),
    );

console.log('PASS: Employee cannot read another municipality reports');
    // Test 10: Inactive citizen cannot read their own report.
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'citizens/citizenC'), {
        role: 'citizen',
        accountStatus: 'suspended',
      });

      await setDoc(doc(context.firestore(), 'reports/CMP-002'), {
        citizenId: 'citizenC',
        category: 'Damaged Sidewalk',
        status: 'Pending',
      });
    });

    const citizenC = testEnv.authenticatedContext('citizenC');

    await assertFails(
      getDoc(doc(citizenC.firestore(), 'reports/CMP-002')),
    );

    console.log('PASS: Inactive citizen cannot read their reports');


    // Test 11: Employee can read a report from their municipality.
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'reports/CMP-AMMAN'), {
        citizenId: 'citizenA',
        municipalityId: 'amman',
        category: 'Pothole',
        status: 'Pending',
      });
    });

    await assertSucceeds(
      getDoc(doc(employeeA.firestore(), 'reports/CMP-AMMAN')),
    );

    console.log('PASS: Employee can read their municipality reports');


    // Test 12: Employee can query reports from their municipality.
    const employeeReportsQuery = query(
      collection(employeeA.firestore(), 'reports'),
      where('municipalityId', '==', 'amman'),
    );

    const employeeReports = await assertSucceeds(
      getDocs(employeeReportsQuery),
    );

    if (employeeReports.size !== 1) {
      throw new Error(
        `Expected 1 Amman report, found ${employeeReports.size}`,
      );
    }

    console.log('PASS: Employee can query their municipality reports');

    // Test 13: Employee cannot query another municipality reports.
    const otherMunicipalityQuery = query(
      collection(employeeA.firestore(), 'reports'),
      where('municipalityId', '==', 'irbid'),
    );

    await assertFails(
      getDocs(otherMunicipalityQuery),
    );

    console.log(
      'PASS: Employee cannot query another municipality reports'
    );

    // Test 14: Suspended employee cannot read municipality reports.
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'employees/employeeB'), {
        role: 'employee',
        accountStatus: 'suspended',
        municipalityId: 'amman',
      });
    });

    const employeeB = testEnv.authenticatedContext('employeeB');

    await assertFails(
      getDoc(doc(employeeB.firestore(), 'reports/CMP-AMMAN')),
    );

    console.log(
      'PASS: Suspended employee cannot read municipality reports'
    );


  } finally {
    await testEnv.cleanup();
  }
}

main().catch((error) => {
  console.error('TEST FAILED:', error);
  process.exitCode = 1;
});