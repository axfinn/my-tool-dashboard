<template>
    <div class="background-container" :style="backgroundStyle"></div>
    <div class="container py-5">
        <div class="text-center mb-4">
            <h1>我的工具导航</h1>
            <p class="lead">一个集中管理常用工具的导航页</p>
        </div>

        <div class="row justify-content-center mb-4">
            <div class="col-md-8 col-lg-6">
                <div class="input-group shadow-sm rounded-pill overflow-hidden">
                    <input type="text" v-model="searchTerm" class="form-control border-0 ps-4" placeholder="实时搜索工具...">
                    <button class="btn btn-primary px-4" @click="openToolModal()">添加新工具</button>
                </div>
            </div>
        </div>

        <div class="d-flex align-items-center mb-3">
            <div class="form-check form-switch me-3">
                <input class="form-check-input" type="checkbox" id="backgroundRotationSwitch" v-model="isBackgroundRotationEnabled" @change="toggleBackgroundRotation">
                <label class="form-check-label" for="backgroundRotationSwitch">背景轮播</label>
            </div>
            <label for="backgroundBlurRange" class="form-label mb-0 me-2">背景模糊度:</label>
            <input type="range" class="form-range" id="backgroundBlurRange" min="0" max="10" step="0.1" v-model="backgroundBlur">
        </div>

        <div v-for="category in filteredCategories" :key="category.name">
            <h2 class="category-title">{{ category.name }}</h2>
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
                <ToolCard
                    v-for="tool in category.tools"
                    :key="tool.id"
                    :tool="tool"
                    @edit="openToolModal($event, category.name)"
                    @delete="deleteTool($event)"
                />
            </div>
        </div>

        <ToolModal
            :tool="currentTool"
            :isEditMode="isEditMode"
            :uniqueCategoryNames="uniqueCategoryNames"
            @save="saveTool"
        />

        <MusicPlayer />
        <PetCard />
        <PendulumComponent />
    </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { Modal } from 'bootstrap';
import ToolCard from './components/ToolCard.vue';
import ToolModal from './components/ToolModal.vue';
import MusicPlayer from './components/MusicPlayer.vue';
import PetCard from './components/PetCard.vue';
import PendulumComponent from './components/PendulumComponent.vue';

const STORAGE_KEY = 'my-tools-dashboard-vue';
let toolModalInstance = null;
let backgroundInterval = null;

const categories = ref([]);
const searchTerm = ref('');
const currentTool = ref({
    id: null,
    name: '',
    url: '',
    category: '',
    description: ''
});
const isEditMode = ref(false);

const backgroundImages = ref([
    'https://picsum.photos/1920/1080?random=1',
    'https://picsum.photos/1920/1080?random=2',
    'https://picsum.photos/1920/1080?random=3'
]);
const currentBackgroundIndex = ref(0);
const isBackgroundRotationEnabled = ref(true); // New ref for toggle

const defaultData = [
    {
        name: "常用工具",
        tools: [
            { id: "default-1", name: "在线翻译", url: "https://translate.google.com/", description: "谷歌翻译，支持多种语言。" },
            { id: "default-2", name: "时间戳转换", url: "https://www.tool.io/timestamp/", description: "Unix 时间戳和标准日期的相互转换。" }
        ]
    },
    {
        name: "开发工具",
        tools: [
            { id: "default-3", name: "JSON 格式化", url: "https://jsonformatter.curiousconcept.com/", description: "在线验证、格式化和美化 JSON 数据。" },
            { id: "default-4", name: "正则表达式测试", url: "https://regex101.com/", description: "在线测试和调试正则表达式。" }
        ]
    }
];

// Computed Properties
const filteredCategories = computed(() => {
    if (!searchTerm.value) {
        return categories.value;
    }
    const lowerCaseSearchTerm = searchTerm.value.toLowerCase();
    return categories.value.map(category => {
        const filteredTools = category.tools.filter(tool =>
            tool.name.toLowerCase().includes(lowerCaseSearchTerm) ||
            tool.description.toLowerCase().includes(lowerCaseSearchTerm)
        );
        return { ...category, tools: filteredTools };
    }).filter(category => category.tools.length > 0 || category.name.toLowerCase().includes(lowerCaseSearchTerm));
});

const uniqueCategoryNames = computed(() => {
    const names = new Set();
    categories.value.forEach(cat => names.add(cat.name));
    return Array.from(names);
});

const backgroundBlur = ref(0); // New ref for background blur

const backgroundStyle = computed(() => {
    return {
        backgroundImage: `url(${backgroundImages.value[currentBackgroundIndex.value]})`,
        filter: `blur(${backgroundBlur.value}px)`,
    };
});

// Methods
function loadData() {
    const data = localStorage.getItem(STORAGE_KEY);
    if (data) {
        categories.value = JSON.parse(data);
    } else {
        categories.value = defaultData;
        saveData();
    }
}

function saveData() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(categories.value));
}

function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

function findToolById(id) {
    for (const category of categories.value) {
        const tool = category.tools.find(t => t.id === id);
        if (tool) {
            return { tool, category };
        }
    }
    return null;
}

function openToolModal(tool = null, categoryName = '') {
    if (tool) {
        isEditMode.value = true;
        currentTool.value = {
            id: tool.id,
            name: tool.name,
            url: tool.url,
            category: categoryName,
            description: tool.description
        };
    } else {
        isEditMode.value = false;
        currentTool.value = {
            id: null,
            name: '',
            url: '',
            category: '',
            description: ''
        };
    }
    toolModalInstance.show();
}

function saveTool(toolData) {
    if (toolData.id) { // Editing existing tool
        const { tool: oldTool, category: oldCategory } = findToolById(toolData.id);
        if (oldTool) {
            oldTool.name = toolData.name;
            oldTool.url = toolData.url;
            oldTool.description = toolData.description;

            if (oldCategory.name !== toolData.category) {
                // Remove from old category
                oldCategory.tools = oldCategory.tools.filter(t => t.id !== toolData.id);
                if (oldCategory.tools.length === 0) {
                    categories.value = categories.value.filter(c => c.name !== oldCategory.name);
                }
                // Add to new/existing category
                let newCategory = categories.value.find(c => c.name === toolData.category);
                if (!newCategory) {
                    newCategory = { name: toolData.category, tools: [] };
                    categories.value.push(newCategory);
                }
                newCategory.tools.push(oldTool);
            }
        }
    } else { // Adding new tool
        const newTool = { id: generateId(), ...toolData };
        let category = categories.value.find(c => c.name === toolData.category);
        if (category) {
            category.tools.push(newTool);
        } else {
            categories.value.push({ name: toolData.category, tools: [newTool] });
        }
    }
    saveData();
    toolModalInstance.hide();
}

function deleteTool(id) {
    if (confirm('您确定要删除这个工具吗？')) {
        categories.value.forEach(category => {
            category.tools = category.tools.filter(tool => tool.id !== id);
        });
        categories.value = categories.value.filter(category => category.tools.length > 0);
        saveData();
    }
}

function startBackgroundRotation() {
    if (isBackgroundRotationEnabled.value) {
        backgroundInterval = setInterval(() => {
            currentBackgroundIndex.value = (currentBackgroundIndex.value + 1) % backgroundImages.value.length;
        }, 10000); // Change background every 10 seconds
    }
}

function stopBackgroundRotation() {
    if (backgroundInterval) {
        clearInterval(backgroundInterval);
        backgroundInterval = null;
    }
}

function toggleBackgroundRotation() {
    if (isBackgroundRotationEnabled.value) {
        startBackgroundRotation();
    } else {
        stopBackgroundRotation();
    }
}

// Lifecycle Hook
onMounted(() => {
    loadData();
    toolModalInstance = new Modal(document.getElementById('toolModal'));
    startBackgroundRotation(); // Start rotation by default
});

onUnmounted(() => {
    stopBackgroundRotation();
});
</script>

<style>
body {
    margin: 0;
    overflow-x: hidden; /* Prevent horizontal scrollbar */
}

#app {
    position: relative;
    min-height: 100vh;
    z-index: 1;
}

.background-container {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    transition: background-image 1s ease-in-out;
    z-index: -1; /* Send to back */
}

/* App-level styles or overrides */
</style>
