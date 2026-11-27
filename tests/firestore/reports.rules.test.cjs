
const fs = require('node:fs');
const path = require('node:path');

const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const {
  collection,
  deleteDoc,
  deleteField,
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
rules: fs.readFileSync(
  path.resolve(__dirname, '../../firestore.rules'),
  'utf8'
),    },
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

    // Test 15: Employee can update priority
    // for a report belonging to their municipality.
    await assertSucceeds(
      updateDoc(
        doc(employeeA.firestore(), 'reports/CMP-AMMAN'),
        {
          priority: 'high',
        },
      ),
    );

    console.log(
      'PASS: Employee can update priority in their municipality'
    );

    // Test 16: Employee cannot update a report
    // belonging to another municipality.
    await assertFails(
      updateDoc(
        doc(employeeA.firestore(), 'reports/CMP-EMP'),
        {
          priority: 'high',
        },
      ),
    );

    console.log(
      'PASS: Employee cannot update another municipality report'
    );

    // Test 17: Citizen cannot update report priority.
    await assertFails(
      updateDoc(
        doc(citizenA.firestore(), 'reports/CMP-001'),
        {
          priority: 'high',
        },
      ),
    );

    console.log(
      'PASS: Citizen cannot update report priority'
    );

    // Test 18: Employee cannot change category
    // through the priority-only rule.
    await assertFails(
      updateDoc(
        doc(employeeA.firestore(), 'reports/CMP-AMMAN'),
        {
          category: 'Garbage',
        },
      ),
    );

    console.log(
      'PASS: Employee cannot modify restricted fields'
    );

    // Test 19: Employee cannot enter invalid priority.
    await assertFails(
      updateDoc(
        doc(employeeA.firestore(), 'reports/CMP-AMMAN'),
        {
          priority: 'critical',
        },
      ),
    );

    console.log(
      'PASS: Invalid priority values are denied'
    );

    // Test 20: Suspended employee cannot update priority.
    await assertFails(
      updateDoc(
        doc(employeeB.firestore(), 'reports/CMP-AMMAN'),
        {
          priority: 'low',
        },
      ),
    );

    console.log(
      'PASS: Suspended employee cannot update priority'
    );

// Prepare a report containing the proposed classification fields.
await testEnv.withSecurityRulesDisabled(async (context) => {
  await setDoc(
    doc(context.firestore(), 'reports/CMP-CLASSIFICATION'),
    {
      reportId: 'CMP-CLASSIFICATION',
      citizenId: 'citizenA',
      municipalityId: 'amman',
      category: 'pothole',
      aiPredictedCategory: 'garbage',
      citizenSelectedCategory: 'pothole',
      officialCategory: 'water_leak',
      reviewStatus: 'approved',
      status: 'pending',
      priority: 'medium',
    },
  );
});

const employeeClassificationReport = doc(
  employeeA.firestore(),
  'reports/CMP-CLASSIFICATION',
);

const citizenClassificationReport = doc(
  citizenA.firestore(),
  'reports/CMP-CLASSIFICATION',
);

// Test 21: Employee can read all classification fields.
const classificationSnapshot = await assertSucceeds(
  getDoc(employeeClassificationReport),
);

const classificationData = classificationSnapshot.data();

if (
  classificationData.aiPredictedCategory !== 'garbage' ||
  classificationData.citizenSelectedCategory !== 'pothole' ||
  classificationData.officialCategory !== 'water_leak' ||
  classificationData.reviewStatus !== 'approved'
) {
  throw new Error('Classification data does not match');
}

console.log('PASS: Employee can read classification fields');

// Test 22: Citizen can read their own report.
await assertSucceeds(
  getDoc(citizenClassificationReport),
);

console.log('PASS: Citizen can read their classified report');

// Test 23: Another citizen cannot read the report.
await assertFails(
  getDoc(
    doc(
      citizenB.firestore(),
      'reports/CMP-CLASSIFICATION',
    ),
  ),
);

console.log('PASS: Another citizen cannot read classified report');

// Test 24: Citizen cannot change the official category.
await assertFails(
  updateDoc(citizenClassificationReport, {
    officialCategory: 'garbage',
  }),
);

console.log('PASS: Citizen cannot change official category');

// Test 25: Citizen cannot change AI prediction.
await assertFails(
  updateDoc(citizenClassificationReport, {
    aiPredictedCategory: 'pothole',
  }),
);

console.log('PASS: Citizen cannot change AI prediction');

// Test 26: Citizen cannot change review status.
await assertFails(
  updateDoc(citizenClassificationReport, {
    reviewStatus: 'rejected',
  }),
);

console.log('PASS: Citizen cannot change review status');

// Test 27: Authorized employee can update official category.
await assertSucceeds(
  updateDoc(employeeClassificationReport, {
    officialCategory: 'garbage',
  }),
);

console.log(
  'PASS: Authorized employee can update official category'
);

// Test 28: Authorized employee can update review status.
await assertSucceeds(
  updateDoc(employeeClassificationReport, {
    reviewStatus: 'rejected',
  }),
);

console.log(
  'PASS: Authorized employee can update review status'
);
// Test 29: Priority editing still works.
await assertSucceeds(
  updateDoc(employeeClassificationReport, {
    priority: 'high',
  }),
);

console.log('PASS: Priority editing still works');

// Test 30: Priority update preserves classification fields.
const updatedSnapshot = await assertSucceeds(
  getDoc(employeeClassificationReport),
);

const updatedData = updatedSnapshot.data();

if (
  updatedData.priority !== 'high' ||
  updatedData.aiPredictedCategory !== 'garbage' ||
  updatedData.citizenSelectedCategory !== 'pothole' ||
  updatedData.officialCategory !== 'garbage' ||
  updatedData.reviewStatus !== 'rejected'
) {
  throw new Error('Unexpected classification modification');
}

console.log(
  'PASS: Priority update preserves classification fields'
);

// Test 31: Employee cannot modify AI prediction.
await assertFails(
  updateDoc(employeeClassificationReport, {
    aiPredictedCategory: 'pothole',
  }),
);

console.log('PASS: Employee cannot modify AI prediction');

// Test 32: Employee cannot modify citizen selection.
await assertFails(
  updateDoc(employeeClassificationReport, {
    citizenSelectedCategory: 'garbage',
  }),
);

console.log('PASS: Employee cannot modify citizen selection');

// Test 33: Invalid official categories are denied.
await assertFails(
  updateDoc(employeeClassificationReport, {
    officialCategory: 'invalid_category',
  }),
);

console.log('PASS: Invalid official category is denied');

// Test 34: Invalid review decisions are denied.
await assertFails(
  updateDoc(employeeClassificationReport, {
    reviewStatus: 'invalid_status',
  }),
);

console.log('PASS: Invalid review status is denied');

// Test 35: Employee cannot update multiple fields together.
await assertFails(
  updateDoc(employeeClassificationReport, {
    officialCategory: 'pothole',
    priority: 'low',
  }),
);

console.log('PASS: Multiple-field updates are denied');

// Test 36: Employee cannot delete protected fields.
await assertFails(
  updateDoc(employeeClassificationReport, {
    aiPredictedCategory: deleteField(),
  }),
);

console.log('PASS: Protected field deletion is denied');

// Test 37: Employee cannot delete official category.
await assertFails(
  updateDoc(employeeClassificationReport, {
    officialCategory: deleteField(),
  }),
);

console.log('PASS: Official category deletion is denied');

// Test 38: Employee cannot delete review status.
await assertFails(
  updateDoc(employeeClassificationReport, {
    reviewStatus: deleteField(),
  }),
);

console.log('PASS: Review status deletion is denied');

// Test 39: Employee cannot change report ownership.
await assertFails(
  updateDoc(employeeClassificationReport, {
    citizenId: 'citizenB',
  }),
);

console.log('PASS: Report ownership modification is denied');

// Test 40: Employee cannot change report municipality.
await assertFails(
  updateDoc(employeeClassificationReport, {
    municipalityId: 'irbid',
  }),
);

console.log('PASS: Municipality modification is denied');

// Test 41: Suspended employee cannot update category.
await assertFails(
  updateDoc(
    doc(
      employeeB.firestore(),
      'reports/CMP-CLASSIFICATION',
    ),
    {
      officialCategory: 'pothole',
    },
  ),
);

console.log('PASS: Suspended employee cannot update category');

// Test 42: Suspended employee cannot update review.
await assertFails(
  updateDoc(
    doc(
      employeeB.firestore(),
      'reports/CMP-CLASSIFICATION',
    ),
    {
      reviewStatus: 'approved',
    },
  ),
);

console.log('PASS: Suspended employee cannot update review');

// Test 43: Employee cannot update another municipality category.
await assertFails(
  updateDoc(
    doc(employeeA.firestore(), 'reports/CMP-EMP'),
    {
      officialCategory: 'pothole',
    },
  ),
);

console.log('PASS: Cross-municipality category update is denied');

// Test 44: Employee cannot review another municipality report.
await assertFails(
  updateDoc(
    doc(employeeA.firestore(), 'reports/CMP-EMP'),
    {
      reviewStatus: 'approved',
    },
  ),
);

console.log('PASS: Cross-municipality review is denied');

// Test 45: Authorized employee can approve a report.
await assertSucceeds(
  updateDoc(employeeClassificationReport, {
    reviewStatus: 'approved',
  }),
);

console.log('PASS: Authorized employee can approve report');

// Test 46: Employee can correct official category again.
await assertSucceeds(
  updateDoc(employeeClassificationReport, {
    officialCategory: 'water_leak',
  }),
);

console.log('PASS: Authorized employee can correct category');

// Prepare a report without an assigned municipality.
await testEnv.withSecurityRulesDisabled(async (context) => {
  await setDoc(
    doc(context.firestore(), 'reports/CMP-UNASSIGNED'),
    {
      citizenId: 'citizenA',
      municipalityId: null,
      category: 'pothole',
      status: 'pending',
      priority: 'medium',
    },
  );
});

const unassignedReport = doc(
  employeeA.firestore(),
  'reports/CMP-UNASSIGNED',
);

// Test 47: Unassigned report category cannot be updated.
await assertFails(
  updateDoc(unassignedReport, {
    officialCategory: 'garbage',
  }),
);

console.log('PASS: Unassigned report category update is denied');

// Test 48: Unassigned report cannot be reviewed.
await assertFails(
  updateDoc(unassignedReport, {
    reviewStatus: 'approved',
  }),
);

console.log('PASS: Unassigned report review is denied');

// Test 49: Unauthenticated users cannot update classification.
await assertFails(
  updateDoc(
    doc(
      guest.firestore(),
      'reports/CMP-CLASSIFICATION',
    ),
    {
      officialCategory: 'pothole',
    },
  ),
);

console.log('PASS: Guest classification update is denied');

// Test 50: Verify final saved data and protected fields.
const finalSnapshot = await assertSucceeds(
  getDoc(employeeClassificationReport),
);

const finalData = finalSnapshot.data();

if (
  finalData.officialCategory !== 'water_leak' ||
  finalData.reviewStatus !== 'approved' ||
  finalData.aiPredictedCategory !== 'garbage' ||
  finalData.citizenSelectedCategory !== 'pothole' ||
  finalData.category !== 'pothole' ||
  finalData.priority !== 'high' ||
  finalData.status !== 'pending' ||
  finalData.citizenId !== 'citizenA' ||
  finalData.municipalityId !== 'amman'
) {
  throw new Error('Final report data verification failed');
}

console.log('PASS: Final report data integrity verified');

  } finally {
    await testEnv.cleanup();
  }
}

main().catch((error) => {
  console.error('TEST FAILED:', error);
  process.exitCode = 1;
});