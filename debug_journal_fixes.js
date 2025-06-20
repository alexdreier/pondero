// Debug script to test journal response functionality
// Copy and paste this into browser console on a journal page

console.log("🔍 Debugging Journal Response Functionality");
console.log("============================================");

// Check if we're on a journal page
const journalQuestions = document.getElementById('journal-questions');
if (!journalQuestions) {
    console.error("❌ Not on a journal page or journal-questions element not found");
} else {
    console.log("✅ Found journal-questions element");
}

// Check for auto-save fields
const autosaveFields = document.querySelectorAll('[data-autosave="true"]');
console.log(`📝 Found ${autosaveFields.length} auto-save fields`);

if (autosaveFields.length === 0) {
    console.error("❌ No auto-save fields found - form fields may not have loaded correctly");
} else {
    console.log("✅ Auto-save fields detected:");
    autosaveFields.forEach((field, index) => {
        console.log(`   ${index + 1}. ${field.tagName} - ID: ${field.id} - Type: ${field.type || 'N/A'}`);
        console.log(`      Question ID: ${field.dataset.questionId || 'MISSING'}`);
    });
}

// Check if Trix editor is loaded
if (typeof Trix !== 'undefined') {
    console.log("✅ Trix editor is loaded");
} else {
    console.warn("⚠️  Trix editor not loaded - rich text editing may not work");
}

// Test auto-save function
if (typeof autoSaveResponse === 'function') {
    console.log("✅ autoSaveResponse function is available");
} else {
    console.error("❌ autoSaveResponse function not found - auto-save won't work");
}

// Check for CSRF token
const csrfToken = document.querySelector('[name="csrf-token"]');
if (csrfToken) {
    console.log("✅ CSRF token found");
} else {
    console.error("❌ CSRF token missing - AJAX requests will fail");
}

// Test responses endpoint
console.log("🌐 Testing /responses endpoint...");
fetch('/responses', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken ? csrfToken.content : ''
    },
    body: JSON.stringify({
        response: { content: 'test' },
        question_id: 'test'
    })
})
.then(response => {
    console.log(`📡 /responses endpoint responded with status: ${response.status}`);
    if (response.status === 422) {
        console.log("ℹ️  422 error expected for test data - endpoint is working");
    }
    return response.text();
})
.then(data => {
    console.log("📄 Response body:", data);
})
.catch(error => {
    console.error("❌ /responses endpoint error:", error);
});

// Instructions for manual testing
console.log("\n🧪 Manual Testing Instructions:");
console.log("1. Try typing in a text field");
console.log("2. Look for 'Saving...' indicator in top-right");
console.log("3. Check browser Network tab for /responses POST requests");
console.log("4. Refresh page and see if text persists");

// Check for form fields with correct names
const responseFields = document.querySelectorAll('[name^="response[content]"]');
console.log(`📋 Found ${responseFields.length} fields with response[content] names`);

// Check event listeners
console.log("\n🎯 Testing event listeners...");
if (autosaveFields.length > 0) {
    const testField = autosaveFields[0];
    console.log(`Testing events on: ${testField.tagName} #${testField.id}`);
    
    // Test input event
    testField.dispatchEvent(new Event('input', { bubbles: true }));
    console.log("✅ Dispatched input event");
    
    // Test change event  
    testField.dispatchEvent(new Event('change', { bubbles: true }));
    console.log("✅ Dispatched change event");
}