<template>
    <span class="text-white ms-3">
        <span v-if="newVersionAvailable" class="badge bg-warning text-dark me-2">有新版本!</span>
        <button v-if="newVersionAvailable" class="btn btn-sm btn-info" @click="goToReleasePage">
            更新到 {{ latestVersion }}
        </button>
        <span v-else-if="!loading && !error" class="text-white-50">已是最新版本</span>
        <span v-else-if="loading" class="text-white-50">检查更新中...</span>
        <span v-else-if="error" class="text-danger">检查更新失败</span>
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
/* Add any specific styles for the version checker here */
</style>
