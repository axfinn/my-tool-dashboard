<template>
    <div class="background-container" :style="backgroundStyle"></div>
    <div class="container py-5">
        <div class="github-link-container">
            <a href="https://github.com/your-username/your-repo" target="_blank" class="github-link">
                <iframe src="https://ghbtns.com/github-btn.html?user=axfinn&repo=my-tool-dashboard&type=star&count=true&size=large" frameborder="0" scrolling="0" width="170" height="30" title="GitHub"></iframe>
                <iframe src="https://ghbtns.com/github-btn.html?user=axfinn&type=follow&count=true&size=large" frameborder="0" scrolling="0" width="170" height="30" title="GitHub"></iframe>
            </a>
        </div>
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

        <div class="controls-container" :class="{ 'expanded': isControlsExpanded }" @mouseenter="handleMouseEnterControls" @mouseleave="handleMouseLeaveControls">
            <button class="toggle-controls-btn" @click="isControlsExpanded = !isControlsExpanded">
                {{ isControlsExpanded ? '&#9660;' : '&#9658;' }} <!-- Down/Right arrow -->
            </button>
            <div ref="controlsContent" :style="controlsContentStyle">
    <div class="d-flex flex-column">
        <div class="form-check form-switch form-check-lg mb-2">
            <input class="form-check-input" type="checkbox" id="backgroundRotationSwitch" v-model="isBackgroundRotationEnabled" @change="toggleBackgroundRotation">
            <label class="form-check-label text-white" for="backgroundRotationSwitch">背景轮播</label>
        </div>
        <div class="mb-2">
            <label for="backgroundBlurRange" class="form-label mb-0 me-2 text-white">背景模糊度:</label>
            <input type="range" class="form-range" id="backgroundBlurRange" min="0" max="10" step="0.1" v-model="backgroundBlur">
        </div>
        <div class="form-check form-switch form-check-lg mb-2">
            <input class="form-check-input" type="checkbox" id="pendulumVisibleSwitch" v-model="isPendulumVisible">
            <label class="form-check-label text-white" for="pendulumVisibleSwitch">显示小摆锤</label>
        </div>
        <div class="form-check form-switch form-check-lg mb-2">
            <input class="form-check-input" type="checkbox" id="pendulumMovableSwitch" v-model="isPendulumMovable">
            <label class="form-check-label text-white" for="pendulumMovableSwitch">小摆锤可移动</label>
        </div>
        <div class="form-check form-switch form-check-lg mb-2">
            <input class="form-check-input" type="checkbox" id="musicPlayerVisibleSwitch" v-model="isMusicPlayerVisible">
            <label class="form-check-label text-white" for="musicPlayerVisibleSwitch">显示音乐播放器</label>
        </div>
        <div class="form-check form-switch form-check-lg mb-2">
            <input class="form-check-input" type="checkbox" id="musicPlayerMovableSwitch" v-model="isMusicPlayerMovable">
            <label class="form-check-label text-white" for="musicPlayerMovableSwitch">音乐播放器可移动</label>
        </div>
        <div class="form-check form-switch form-check-lg mb-2">
            <input class="form-check-input" type="checkbox" id="petCardVisibleSwitch" v-model="isPetCardVisible">
            <label class="form-check-label text-white" for="petCardVisibleSwitch">显示宠物</label>
        </div>
        <div class="form-check form-switch form-check-lg mb-2">
            <input class="form-check-input" type="checkbox" id="petCardMovableSwitch" v-model="isPetCardMovable">
            <label class="form-check-label text-white" for="petCardMovableSwitch">宠物可移动</label>
        </div>
        <div class="form-check form-switch form-check-lg mb-2">
            <input class="form-check-input" type="checkbox" id="timeWidgetVisibleSwitch" v-model="isTimeWidgetVisible">
            <label class="form-check-label text-white" for="timeWidgetVisibleSwitch">显示时间摆件</label>
        </div>
        <div class="form-check form-switch form-check-lg mb-2">
            <input class="form-check-input" type="checkbox" id="timeWidgetMovableSwitch" v-model="isTimeWidgetMovable">
            <label class="form-check-label text-white" for="timeWidgetMovableSwitch">时间摆件可移动</label>
        </div>
        <hr class="text-white-50 my-3" v-if="isAdminMode">
        <h6 class="text-white mb-2" v-if="isAdminMode">备案信息配置</h6>
        <div class="mb-2" v-if="isAdminMode">
            <label for="icpNumberInput" class="form-label mb-0 me-2 text-white">备案号:</label>
            <input type="text" class="form-control" id="icpNumberInput" v-model="icpNumber" placeholder="请输入备案号">
        </div>
        <div class="form-check form-switch form-check-lg mb-2" v-if="isAdminMode">
            <input class="form-check-input" type="checkbox" id="icpVisibleSwitch" v-model="icpVisible">
            <label class="form-check-label text-white" for="icpVisibleSwitch">显示备案号</label>
        </div>
        <hr class="text-white-50 my-3" v-if="isAdminMode">
        <h6 class="text-white mb-2" v-if="isAdminMode">背景音乐配置</h6>
        <div class="mb-2" v-if="isAdminMode">
            <button class="btn btn-secondary w-100" @click="openMusicConfigModal">配置背景音乐</button>
        </div>

        <MusicConfigModal
            ref="musicConfigModalRef"
            :musicUrls="musicUrls"
            @save="(newUrls) => { musicUrls = newUrls; saveUserPreferences(); }"
        ></MusicConfigModal>
    </div>
</div>
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
            ref="toolModalRef"
            :tool="currentTool"
            :isEditMode="isEditMode"
            :uniqueCategoryNames="uniqueCategoryNames"
            @save="saveTool"
            @close="toolModalRef.hide()"
        />

        <MusicPlayer :is-visible="isMusicPlayerVisible" :is-movable="isMusicPlayerMovable" :music-urls="musicUrls" />
        <PetCard :is-visible="isPetCardVisible" :is-movable="isPetCardMovable" />
        <PendulumComponent :is-visible="isPendulumVisible" :is-movable="isPendulumMovable" />
        <TimeWidget :is-visible="isTimeWidgetVisible" :is-movable="isTimeWidgetMovable" />
    </div>
    <footer class="footer mt-auto py-2 bg-transparent">
        <div class="container text-center">
            <span v-if="icpVisible" class="text-white"><a :href="'https://beian.miit.gov.cn/'" target="_blank" class="text-white text-decoration-none">{{ icpNumber }}</a></span>
            <button class="btn btn-link text-white-50 ms-3" @click="toggleAdminMode">
                {{ isAdminMode ? '退出管理员模式' : '管理员登录' }}
            </button>
        </div>
    </footer>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import ToolCard from './components/ToolCard.vue';
import ToolModal from './components/ToolModal.vue';
import MusicPlayer from './components/MusicPlayer.vue';
import PetCard from './components/PetCard.vue';
import PendulumComponent from './components/PendulumComponent.vue';
import TimeWidget from './components/TimeWidget.vue';
import MusicConfigModal from './components/MusicConfigModal.vue';

const STORAGE_KEY_TOOLS = 'my-tools-dashboard-vue-tools';
const STORAGE_KEY_PREFERENCES = 'my-tools-dashboard-vue-preferences';
let toolModalRef = ref(null);
let musicConfigModalRef = ref(null);
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
const isBackgroundRotationEnabled = ref(true);
const backgroundBlur = ref(0); // New ref for background blur
const isPendulumVisible = ref(true); // New ref for pendulum visibility
const isPendulumMovable = ref(true);
const isMusicPlayerVisible = ref(true);
const isMusicPlayerMovable = ref(true);
const isPetCardVisible = ref(true);
const isPetCardMovable = ref(true);
const isTimeWidgetVisible = ref(true);
const isTimeWidgetMovable = ref(true);
const icpNumber = ref('京ICP备xxxxxxxx号');
const icpVisible = ref(true);
const isControlsExpanded = ref(false);
const isAdminMode = ref(false); // New ref for admin mode
const ADMIN_PASSWORD = 'admin'; // Hardcoded admin password - FOR DEMO ONLY, NOT SECURE

const musicUrls = ref([
    'https://www.bensound.com/bensound-music/bensound-ukulele.mp3',
    'https://www.bensound.com/bensound-music/bensound-sunny.mp3',
    'https://www.bensound.com/bensound-music/bensound-creativeminds.mp3'
]);

const defaultData = [
    {
        name: '常用工具',
        tools: [
            { id: '1', name: 'Google', url: 'https://www.google.com', description: '全球最大的搜索引擎' },
            { id: '2', name: 'GitHub', url: 'https://github.com', description: '代码托管平台' },
            { id: '3', name: 'Stack Overflow', url: 'https://stackoverflow.com', description: '程序员问答社区' }
        ]
    },
    {
        name: '开发工具',
        tools: [
            { id: '4', name: 'Vue.js', url: 'https://vuejs.org/', description: '渐进式JavaScript框架' },
            { id: '5', name: 'React', url: 'https://react.dev/', description: '用于构建用户界面的JavaScript库' }
        ]
    }
];




const controlsContent = ref(null);

const controlsContentHeight = computed(() => {
    // A sufficiently large fixed value for max-height when expanded
    // This avoids layout thrashing from dynamic scrollHeight calculation during animation
    return isControlsExpanded.value ? '650px' : '0px'; 
});

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

const backgroundStyle = computed(() => {
    return {
        backgroundImage: `url(${backgroundImages.value[currentBackgroundIndex.value]})`,
        filter: `blur(${backgroundBlur.value}px)`,
    };
});

const controlsContentStyle = computed(() => {
    return {
        maxHeight: isControlsExpanded.value ? controlsContentHeight.value : '0',
        overflow: 'hidden',
        transition: 'max-height 0.4s cubic-bezier(0.25, 0.8, 0.25, 1)'
    };
});



// Methods
function loadData() {
    const data = localStorage.getItem(STORAGE_KEY_TOOLS);
    if (data) {
        categories.value = JSON.parse(data);
    } else {
        categories.value = defaultData;
        saveData();
    }
}

function saveData() {
    localStorage.setItem(STORAGE_KEY_TOOLS, JSON.stringify(categories.value));
}

function loadUserPreferences() {
    const preferences = JSON.parse(localStorage.getItem(STORAGE_KEY_PREFERENCES) || '{}');
    isBackgroundRotationEnabled.value = preferences.isBackgroundRotationEnabled !== undefined ? preferences.isBackgroundRotationEnabled : true;
    backgroundBlur.value = preferences.backgroundBlur !== undefined ? preferences.backgroundBlur : 0;
    isPendulumVisible.value = preferences.isPendulumVisible !== undefined ? preferences.isPendulumVisible : true;
    isPendulumMovable.value = preferences.isPendulumMovable !== undefined ? preferences.isPendulumMovable : true;
    isMusicPlayerVisible.value = preferences.isMusicPlayerVisible !== undefined ? preferences.isMusicPlayerVisible : true;
    isMusicPlayerMovable.value = preferences.isMusicPlayerMovable !== undefined ? preferences.isMusicPlayerMovable : true;
    isPetCardVisible.value = preferences.isPetCardVisible !== undefined ? preferences.isPetCardVisible : true;
    isPetCardMovable.value = preferences.isPetCardMovable !== undefined ? preferences.isPetCardMovable : true;
    isTimeWidgetVisible.value = preferences.isTimeWidgetVisible !== undefined ? preferences.isTimeWidgetVisible : true;
    isTimeWidgetMovable.value = preferences.isTimeWidgetMovable !== undefined ? preferences.isTimeWidgetMovable : true;
    icpNumber.value = preferences.icpNumber !== undefined ? preferences.icpNumber : '京ICP备xxxxxxxx号';
    icpVisible.value = preferences.icpVisible !== undefined ? preferences.icpVisible : true;
    isAdminMode.value = preferences.isAdminMode !== undefined ? preferences.isAdminMode : false;
    musicUrls.value = preferences.musicUrls !== undefined ? preferences.musicUrls : [
        'https://www.bensound.com/bensound-music/bensound-ukulele.mp3',
        'https://www.bensound.com/bensound-music/bensound-sunny.mp3',
        'https://www.bensound.com/bensound-music/bensound-creativeminds.mp3'
    ];
}

function saveUserPreferences() {
    const preferences = {
        isBackgroundRotationEnabled: isBackgroundRotationEnabled.value,
        backgroundBlur: backgroundBlur.value,
        isPendulumVisible: isPendulumVisible.value,
        isPendulumMovable: isPendulumMovable.value,
        isMusicPlayerVisible: isMusicPlayerVisible.value,
        isMusicPlayerMovable: isMusicPlayerMovable.value,
        isPetCardVisible: isPetCardVisible.value,
        isPetCardMovable: isPetCardMovable.value,
        isTimeWidgetVisible: isTimeWidgetVisible.value,
        isTimeWidgetMovable: isTimeWidgetMovable.value,
        icpNumber: icpNumber.value,
        icpVisible: icpVisible.value,
        isAdminMode: isAdminMode.value,
        musicUrls: musicUrls.value,
    };
    localStorage.setItem(STORAGE_KEY_PREFERENCES, JSON.stringify(preferences));
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
    if (toolModalRef.value) {
        toolModalRef.value.show();
    }
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
    if (toolModalRef.value) {
        toolModalRef.value.hide();
    } else {
        console.error('App.vue: toolModalRef is not initialized!');
    }
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

const handleMouseEnterControls = () => {
    isControlsExpanded.value = true;
};

const handleMouseLeaveControls = () => {
    isControlsExpanded.value = false;
};

const toggleAdminMode = () => {
    if (isAdminMode.value) {
        isAdminMode.value = false;
        alert('已退出管理员模式。');
    } else {
        const password = prompt('请输入管理员密码：');
        if (password === ADMIN_PASSWORD) {
            isAdminMode.value = true;
            alert('已进入管理员模式。');
        } else {
            alert('密码错误！');
        }
    }
};

const openMusicConfigModal = () => {
    if (musicConfigModalRef.value) {
        musicConfigModalRef.value.showModal();
    }
};

// Lifecycle Hook
onMounted(() => {
    loadData();
    loadUserPreferences();
    startBackgroundRotation(); // Start rotation by default
});

watch([isBackgroundRotationEnabled, backgroundBlur, isPendulumVisible, isPendulumMovable, isMusicPlayerVisible, isMusicPlayerMovable, isPetCardVisible, isPetCardMovable, isTimeWidgetVisible, isTimeWidgetMovable, icpNumber, icpVisible, isAdminMode, musicUrls], () => {
    saveUserPreferences();
});
</script>


