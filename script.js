const defaultTasks = [
  {
    id: 1,
    title: "Review recent account login activity",
    description: "Check whether recent sign in activity looks normal.",
    category: "Account Review",
    points: 10,
    completed: false
  },
  {
    id: 2,
    title: "Confirm two factor authentication is enabled",
    description: "Verify that your important account still has 2FA turned on.",
    category: "Authentication",
    points: 15,
    completed: false
  },
  {
    id: 3,
    title: "Check connected third party apps",
    description: "Review linked apps and remove anything unfamiliar.",
    category: "Privacy",
    points: 12,
    completed: false
  }
];

let state = {
  user: null,
  streak: 3,
  points: 45,
  level: 1,
  tasks: JSON.parse(JSON.stringify(defaultTasks)),
  activity: ["Logged in to SecuRoutine", "Viewed today’s security tasks"],
  rewards: ["Starter badge unlocked", "3 day streak milestone reached"]
};

const authScreen = document.getElementById("authScreen");
const dashboard = document.getElementById("dashboard");
const loginTab = document.getElementById("loginTab");
const registerTab = document.getElementById("registerTab");
const loginForm = document.getElementById("loginForm");
const registerForm = document.getElementById("registerForm");
const authMessage = document.getElementById("authMessage");

loginTab.addEventListener("click", () => {
  loginTab.classList.add("active");
  registerTab.classList.remove("active");
  loginForm.classList.remove("hidden");
  registerForm.classList.add("hidden");
  authMessage.classList.add("hidden");
});

registerTab.addEventListener("click", () => {
  registerTab.classList.add("active");
  loginTab.classList.remove("active");
  registerForm.classList.remove("hidden");
  loginForm.classList.add("hidden");
  authMessage.classList.add("hidden");
});

function login() {
  const email = document.getElementById("loginEmail").value.trim();
  state.user = { name: "Demo User", email };
  showDashboard();
}

function register() {
  const name = document.getElementById("registerName").value.trim() || "New User";
  const email = document.getElementById("registerEmail").value.trim() || "new@securoutine.com";
  const age = document.getElementById("registerAge").value || "Adult User";
  state.user = { name, email, age };
  authMessage.textContent = "Account created successfully. You can now use the prototype.";
  authMessage.classList.remove("hidden");
  showDashboard();
}

function showDashboard() {
  authScreen.classList.add("hidden");
  dashboard.classList.remove("hidden");
  document.getElementById("userName").textContent = state.user.name;
  renderDashboard();
}

function renderDashboard() {
  const completedCount = state.tasks.filter(task => task.completed).length;
  document.getElementById("streakValue").textContent = state.streak;
  document.getElementById("pointsValue").textContent = state.points;
  document.getElementById("levelValue").textContent = state.level;
  document.getElementById("completedValue").textContent = completedCount;

  const taskList = document.getElementById("taskList");
  taskList.innerHTML = "";

  state.tasks.forEach(task => {
    const div = document.createElement("div");
    div.className = `task ${task.completed ? "done" : ""}`;
    div.innerHTML = `
      <div class="task-top">
        <div>
          <h4>${task.title}</h4>
          <p class="muted">${task.description}</p>
        </div>
        <span class="badge">${task.category}</span>
      </div>
      <p><strong>${task.points} points</strong></p>
      <button class="${task.completed ? "ghost" : "secondary"}" ${task.completed ? "disabled" : ""} onclick="completeTask(${task.id})">
        ${task.completed ? "Completed" : "Mark as Complete"}
      </button>
    `;
    taskList.appendChild(div);
  });

  const activityList = document.getElementById("activityList");
  activityList.innerHTML = state.activity.map(item => `<li>${item}</li>`).join("");

  const rewardList = document.getElementById("rewardList");
  rewardList.innerHTML = state.rewards.map(item => `<li>${item}</li>`).join("");
}

function completeTask(taskId) {
  const task = state.tasks.find(t => t.id === taskId);
  if (!task || task.completed) return;

  task.completed = true;
  state.points += task.points;
  state.activity.unshift(`Completed task: ${task.title}`);

  const allCompleted = state.tasks.every(t => t.completed);
  if (allCompleted) {
    state.streak += 1;
    state.points += 20;
    state.activity.unshift("Completed all daily tasks and extended streak");
    state.rewards.unshift(`${state.streak} day streak updated`);
  }

  state.level = Math.floor(state.points / 50) + 1;
  renderDashboard();
}

function saveSettings() {
  const settingsMessage = document.getElementById("settingsMessage");
  settingsMessage.classList.remove("hidden");
  setTimeout(() => settingsMessage.classList.add("hidden"), 1200);
  state.activity.unshift("Updated reminder settings");
  renderDashboard();
}

function resetTasks() {
  state.tasks = JSON.parse(JSON.stringify(defaultTasks));
  state.activity.unshift("Reset prototype tasks for another demo");
  renderDashboard();
}

function logout() {
  authScreen.classList.remove("hidden");
  dashboard.classList.add("hidden");
  state.user = null;
}
