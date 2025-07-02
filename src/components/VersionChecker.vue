<template>
    <span class="version-checker-container ms-3">
        <span v-if="loading" class="text-white-50">
            <i class="fas fa-spinner fa-spin me-1"></i>检查更新中...
        </span>
        <span v-else-if="error" class="text-muted">
            <i class="fas fa-times-circle me-1"></i>检查更新失败
        </span>
        <span v-else-if="newVersionAvailable">
            <span class="badge bg-warning text-dark me-2"><i class="fas fa-exclamation-triangle me-1"></i>有新版本!</span>
            <button class="btn btn-sm btn-info" @click="goToReleasePage">
                <i class="fas fa-download me-1"></i>更新到 {{ latestVersion }}
            </button>
        </span>
        <span v-else class="text-white-50">
            <i class="fas fa-check-circle me-1"></i>已是最新版本
        </span>
    </span>
</template>

<script setup>
import { ref, onMounted, defineProps } from 'vue';

const props = defineProps({
    currentVersion: {
        type: String,
        required: true
    }
});

const latestVersion = ref('');
const newVersionAvailable = ref(false);
const loading = ref(true);
const error = ref(false);

const GITHUB_REPO_OWNER = 'axfinn';
const GITHUB_REPO_NAME = 'my-tool-dashboard';

const fetchLatestRelease = async () => {
    loading.value = true;
    error.value = false;
    try {
        const response = await fetch(`https://api.github.com/repos/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}/releases/latest`);
        if (!response.ok) {
            throw new Error(`GitHub API error: ${response.statusText}`);
        }
        const data = await response.json();
        latestVersion.value = data.tag_name.replace(/^v/, ''); // Remove 'v' prefix if present
        
        // Simple version comparison (e.g., 0.1.1 vs 0.1.2)
        if (compareVersions(latestVersion.value, props.currentVersion) > 0) {
            newVersionAvailable.value = true;
        }
    } catch (e) {
        console.error('Failed to fetch latest release:', e);
        error.value = true;
    } finally {
        loading.value = false;
    }
};

const compareVersions = (v1, v2) => {
    const parts1 = v1.split('.').map(Number);
    const parts2 = v2.split('.').map(Number);

    for (let i = 0; i < Math.max(parts1.length, parts2.length); i++) {
        const p1 = parts1[i] || 0;
        const p2 = parts2[i] || 0;

        if (p1 > p2) return 1;
        if (p1 < p2) return -1;
    }
    return 0;
};

const goToReleasePage = () => {
    window.open(`https://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}/releases/latest`, '_blank');
};

onMounted(() => {
    fetchLatestRelease();
});
</script>

<style scoped>
.version-checker-container {
    display: inline-flex;
    align-items: center;
    font-size: 0.9rem;
}

.btn-info {
    background-color: #17a2b8;
    border-color: #17a2b8;
    color: white;
}

.btn-info:hover {
    background-color: #138496;
    border-color: #117a8b;
}

.badge {
    font-size: 0.8em;
    padding: 0.4em 0.6em;
    vertical-align: middle;
}
</style>