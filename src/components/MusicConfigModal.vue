<template>
    <div class="modal fade" id="musicConfigModal" tabindex="-1" aria-labelledby="musicConfigModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="musicConfigModalLabel">背景音乐配置</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="newMusicUrl" class="form-label">添加新音乐URL</label>
                        <div class="input-group">
                            <input type="url" class="form-control" id="newMusicUrl" v-model="newMusicUrl" placeholder="https://example.com/music.mp3">
                            <button class="btn btn-primary" @click="addMusicUrl">添加</button>
                        </div>
                    </div>

                    <h6>当前音乐列表:</h6>
                    <ul class="list-group">
                        <li class="list-group-item d-flex justify-content-between align-items-center" v-for="(url, index) in localMusicUrls" :key="index">
                            <span class="text-truncate me-2">{{ url }}</span>
                            <div>
                                <button class="btn btn-sm btn-info me-2" @click="editMusicUrl(index)">编辑</button>
                                <button class="btn btn-sm btn-danger" @click="removeMusicUrl(index)">删除</button>
                            </div>
                        </li>
                        <li class="list-group-item text-muted" v-if="localMusicUrls.length === 0">暂无音乐URL</li>
                    </ul>

                    <div class="mt-3" v-if="editingIndex !== null">
                        <h6>编辑音乐URL:</h6>
                        <div class="input-group">
                            <input type="url" class="form-control" v-model="editingMusicUrl" placeholder="https://example.com/music.mp3">
                            <button class="btn btn-success" @click="saveEditedMusicUrl">保存</button>
                            <button class="btn btn-secondary" @click="cancelEdit">取消</button>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" @click="saveChanges">保存所有更改</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, watch, defineProps, defineEmits, onMounted, onUnmounted, defineExpose } from 'vue';
import { Modal } from 'bootstrap';

const props = defineProps({
    musicUrls: { type: Array, default: () => [] }
});

const emits = defineEmits(['save', 'close']);

const localMusicUrls = ref([]);
const newMusicUrl = ref('');
const editingIndex = ref(null);
const editingMusicUrl = ref('');

let modalInstance = null;

onMounted(() => {
    const modalElement = document.getElementById('musicConfigModal');
    if (modalElement) {
        modalInstance = new Modal(modalElement);
    }
});

onUnmounted(() => {
    if (modalInstance) {
        modalInstance.dispose();
        modalInstance = null;
    }
});

watch(() => props.musicUrls, (newVal) => {
    localMusicUrls.value = [...newVal];
}, { immediate: true });

const addMusicUrl = () => {
    if (newMusicUrl.value && newMusicUrl.value.trim() !== '') {
        localMusicUrls.value.push(newMusicUrl.value.trim());
        newMusicUrl.value = '';
    }
};

const editMusicUrl = (index) => {
    editingIndex.value = index;
    editingMusicUrl.value = localMusicUrls.value[index];
};

const saveEditedMusicUrl = () => {
    if (editingIndex.value !== null && editingMusicUrl.value.trim() !== '') {
        localMusicUrls.value[editingIndex.value] = editingMusicUrl.value.trim();
        cancelEdit();
    }
};

const cancelEdit = () => {
    editingIndex.value = null;
    editingMusicUrl.value = '';
};

const removeMusicUrl = (index) => {
    if (confirm('确定要删除此音乐URL吗？')) {
        localMusicUrls.value.splice(index, 1);
        if (editingIndex.value === index) {
            cancelEdit();
        }
    }
};

const saveChanges = () => {
    emits('save', localMusicUrls.value);
    hide();
};

const show = () => {
    if (modalInstance) modalInstance.show();
};

const hide = () => {
    if (modalInstance) modalInstance.hide();
    emits('close');
};

defineExpose({ show, hide });
</script>

<style scoped>
/* Add any specific styles for the modal here */
</style>
