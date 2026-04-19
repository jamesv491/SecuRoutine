const taskCatalog = [
  {
    id: 1,
    title: "Review recent login activity",
    description: "Check whether recent sign in activity looks normal.",
    category: "Login Safety"
  },
  {
    id: 2,
    title: "Confirm 2FA is enabled",
    description: "Verify that two factor authentication is still active.",
    category: "Login Safety"
  },
  {
    id: 3,
    title: "Check connected apps",
    description: "Review linked third party apps and remove unknown ones.",
    category: "Privacy Review"
  },
  {
    id: 4,
    title: "Review privacy settings",
    description: "Check privacy permissions on your main account.",
    category: "Privacy Review"
  },
  {
    id: 5,
    title: "Change an old password",
    description: "Update one password that has not been changed recently.",
    category: "Password Hygiene"
  },
  {
    id: 6,
    title: "Check password strength",
    description: "Make sure an important password is unique and strong.",
    category: "Password Hygiene"
  },
  {
    id: 7,
    title: "Review recovery email",
    description: "Confirm that your recovery email is correct and secure.",
    category: "Login Safety"
  },
  {
    id: 8,
    title: "Remove unused linked services",
    description: "Disconnect apps or sites you no longer use.",
    category: "Privacy Review"
  }
];

let state = {
  user: null,
  profile: null,
  streak: 1,
  points: 0,
  level: 1,
  tasks: [],
  taskSetNumber: 1
};

const authScreen = document.getElementById("authScreen");
const profileScreen = document.getElementById("profileScreen");
const dashboard = document.getElementById("dashboard");

const loginTab = document.getElementById("loginTab");
const registerTab = document.getElementById("registerTab");
const loginForm = document.getElementById("loginForm");
const registerForm = document.getElementById("registerForm");

loginTab.addEventListener("click", () => {
  loginTab.classList.add("active");
  registerTab.classList.remove("active");
  loginForm.classList.remove("hidden");
  registerForm.classList.add("hidden");
});

registerTab.addEventListener("click", () => {
  registerTab.classList.add("active");
  loginTab.classList.remove("active");
  registerForm.classList.remove("hidden");
  loginForm.classList.add("hidden");
});

function login() {
  const email = document.getElementById("loginEmail").value.trim() || "demo@securoutine.com";

  state.user = {
    name: "Existing User",
    email: email
  };

  // giả lập user đã có profile sẵn
  state.profile = {
    displayName: "Existing User",
    experience: "Beginner",
    ageGroup: "Adult User",
    preference: "Login Safety"
  };

  state.streak = 3;
  state.points = 24;
  state.level = 1;
  state.taskSetNumber = 1;
  state.tasks = generateTasks();

  showDashboard();
}

function register() {
  const name = document.getElementById("registerName").value.trim() || "User";
  const email = document.getElementById("registerEmail").value.trim() || "new@securoutine.com";

  state.user = {
    name,
    email
  };

  goToProfileSetup(name);
}

function goToProfileSetup(defaultName) {
  authScreen.classList.add("hidden");
  dashboard.classList.add("hidden");
  profileScreen.classList.remove("hidden");

  document.getElementById("profileDisplayName").value = defaultName || "User";
}

function saveProfile() {
  const displayName = document.getElementById("profileDisplayName").value.trim() || "User";
  const experience = document.getElementById("profileExperience").value || "Beginner";
  const ageGroup = document.getElementById("profileAgeGroup").value || "Adult User";
  const preference = document.getElementById("profilePreference").value || "Login Safety";

  state.profile = {
    displayName,
    experience,
    ageGroup,
    preference
  };

  state.streak = 1;
  state.points = 0;
  state.level = 1;
  state.taskSetNumber = 1;
  state.tasks = generateTasks();

  showDashboard();
}

function generateTasks() {
  if (!state.profile) return [];

  const preferredTasks = taskCatalog.filter(
    task => task.category === state.profile.preference
  );

  const otherTasks = taskCatalog.filter(
    task => task.category !== state.profile.preference
  );

  const shuffledPreferred = shuffleArray([...preferredTasks]);
  const shuffledOther = shuffleArray([...otherTasks]);

  const selected = [];

  if (shuffledPreferred.length > 0) {
    selected.push(shuffledPreferred.shift());
  }

  while (selected.length < 3 && shuffledOther.length > 0) {
    selected.push(shuffledOther.shift());
  }

  while (selected.length < 3 && shuffledPreferred.length > 0) {
    selected.push(shuffledPreferred.shift());
  }

  return selected.map((task, index) => ({
    userTaskId: `${state.taskSetNumber}-${index + 1}-${task.id}`,
    title: task.title,
    description: task.description,
    category: task.category,
    points: calculateTaskPoints(task.category),
    status: "pending"
  }));
}

function calculateTaskPoints(category) {
  if (!state.profile) return 10;

  let base = 10;

  if (category === state.profile.preference) {
    base += 3;
  }

  if (state.profile.experience === "Intermediate") {
    base += 2;
  } else if (state.profile.experience === "Advanced") {
    base += 4;
  }

  return base;
}

function showDashboard() {
  profileScreen.classList.add("hidden");
  authScreen.classList.add("hidden");
  dashboard.classList.remove("hidden");

  document.getElementById("userName").textContent = state.profile.displayName;
  renderDashboard();
}

function renderDashboard() {
  const completedCount = state.tasks.filter(task => task.status === "completed").length;

  document.getElementById("streakValue").textContent = state.streak;
  document.getElementById("pointsValue").textContent = state.points;
  document.getElementById("levelValue").textContent = state.level;
  document.getElementById("completedValue").textContent = completedCount;

  const taskList = document.getElementById("taskList");
  taskList.innerHTML = "";

  state.tasks.forEach(task => {
    const div = document.createElement("div");
    div.className = `task ${task.status === "completed" ? "done" : ""} ${task.status === "skipped" ? "skipped" : ""}`;

    let buttonHtml = "";

    if (task.status === "pending") {
      buttonHtml = `
        <div class="task-actions">
          <button type="button" onclick="completeTask('${task.userTaskId}')">
            Complete (+${task.points})
          </button>
          <button type="button" class="skip-btn" onclick="skipTask('${task.userTaskId}')">
            Skip
          </button>
        </div>
      `;
    } else if (task.status === "completed") {
      buttonHtml = `
        <div class="task-actions">
          <button type="button" disabled>Completed</button>
        </div>
      `;
    } else {
      buttonHtml = `
        <div class="task-actions">
          <button type="button" disabled>Skipped</button>
        </div>
      `;
    }

    div.innerHTML = `
      <h4>${task.title}</h4>
      <p>${task.description}</p>
      ${buttonHtml}
    `;

    taskList.appendChild(div);
  });
}

function completeTask(userTaskId) {
  const task = state.tasks.find(t => t.userTaskId === userTaskId);
  if (!task || task.status !== "pending") return;

  task.status = "completed";
  state.points += task.points;
  state.level = Math.floor(state.points / 40) + 1;

  checkCycleCompletion();
  renderDashboard();
}

function skipTask(userTaskId) {
  const task = state.tasks.find(t => t.userTaskId === userTaskId);
  if (!task || task.status !== "pending") return;

  task.status = "skipped";

  checkCycleCompletion();
  renderDashboard();
}

function checkCycleCompletion() {
  const hasPending = state.tasks.some(task => task.status === "pending");
  if (hasPending) return;

  const completedAll = state.tasks.every(task => task.status === "completed");

  if (completedAll) {
    state.streak += 1;
    state.points += 15;
    state.level = Math.floor(state.points / 40) + 1;
    state.taskSetNumber += 1;
    state.tasks = generateTasks();
  }
}

function generateNewTaskSet() {
  state.taskSetNumber += 1;
  state.tasks = generateTasks();
  renderDashboard();
}

function logout() {
  dashboard.classList.add("hidden");
  profileScreen.classList.add("hidden");
  authScreen.classList.remove("hidden");

  state = {
    user: null,
    profile: null,
    streak: 1,
    points: 0,
    level: 1,
    tasks: [],
    taskSetNumber: 1
  };
}

function shuffleArray(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}