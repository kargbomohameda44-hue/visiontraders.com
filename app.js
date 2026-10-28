/*
  VisionTraders starter frontend.
  1. Create a Supabase project.
  2. Replace SUPABASE_URL and SUPABASE_ANON_KEY below with Project URL and publishable/anon key.
  3. Never add a service_role key to browser code.
*/
const SUPABASE_URL = "PASTE_YOUR_SUPABASE_PROJECT_URL_HERE";
const SUPABASE_ANON_KEY = "PASTE_YOUR_SUPABASE_ANON_KEY_HERE";

let supabaseClient = null;
if (window.supabase && SUPABASE_URL.startsWith("https://") && !SUPABASE_ANON_KEY.startsWith("PASTE_")) {
  supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
}

const form = document.getElementById("authForm");
const message = document.getElementById("authMessage");
const submit = document.getElementById("authSubmit");
let mode = "signup";

document.getElementById("year").textContent = new Date().getFullYear();
document.getElementById("menuButton").addEventListener("click", () => document.getElementById("nav").classList.toggle("open"));
document.querySelectorAll("nav a").forEach(a => a.addEventListener("click", () => document.getElementById("nav").classList.remove("open")));

document.querySelectorAll(".tab").forEach(tab => {
  tab.addEventListener("click", () => {
    mode = tab.dataset.tab;
    document.querySelectorAll(".tab").forEach(t => t.classList.toggle("active", t === tab));
    submit.textContent = mode === "signup" ? "Create account" : "Sign in";
    document.getElementById("password").setAttribute("autocomplete", mode === "signup" ? "new-password" : "current-password");
    message.textContent = "";
  });
});

form.addEventListener("submit", async event => {
  event.preventDefault();
  const email = document.getElementById("email").value.trim();
  const password = document.getElementById("password").value;
  if (!supabaseClient) {
    message.textContent = "Setup required: add your Supabase project URL and anon key in app.js, then configure the SQL schema.";
    return;
  }
  submit.disabled = true;
  message.textContent = "Please wait…";
  try {
    const result = mode === "signup"
      ? await supabaseClient.auth.signUp({ email, password, options: { emailRedirectTo: window.location.origin } })
      : await supabaseClient.auth.signInWithPassword({ email, password });
    if (result.error) throw result.error;
    message.textContent = mode === "signup"
      ? "Account request received. Check your email to verify your address before signing in."
      : "Signed in successfully. Dashboard views should be added after database policies are configured.";
  } catch (error) {
    message.textContent = error.message || "Unable to complete authentication.";
  } finally {
    submit.disabled = false;
  }
});