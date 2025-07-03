<template>
    <!-- 自定义模态框遮罩 -->
    <div v-if="isVisible" class="custom-modal-overlay" @click="closeModal">
        <div class="custom-modal-dialog" @click.stop>
            <div class="custom-modal-content">
                <!-- 模态框头部 -->
                <div class="custom-modal-header">
                    <h5 class="custom-modal-title">
                        <i class="fas fa-music me-2"></i>背景音乐配置
                    </h5>
                    <button type="button" class="custom-close-btn" @click="closeModal">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                
                <!-- 模态框主体 -->
                <div class="custom-modal-body">
                    <!-- 添加新音乐URL -->
                    <div class="config-section">
                        <h6 class="section-title">
                            <i class="fas fa-plus-circle me-2"></i>添加新音乐
                        </h6>
                        <div class="input-group mb-3">
                            <input 
                                type="url" 
                                class="form-control" 
                                v-model="newMusicUrl" 
                                placeholder="请输入音乐URL，例如：https://example.com/music.mp3"
                                @keyup.enter="addMusicUrl"
                                :disabled="isProcessing"
                            >
                            <button 
                                class="btn btn-primary" 
                                @click="addMusicUrl"
                                :disabled="!newMusicUrl.trim() || isProcessing"
                            >
                                <i class="fas fa-plus me-1"></i>添加
                            </button>
                        </div>
                        <small class="text-muted">支持的格式：MP3、WAV、OGG等音频格式</small>
                    </div>

                    <!-- 当前音乐列表 -->
                    <div class="config-section">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="section-title mb-0">
                                <i class="fas fa-list me-2"></i>音乐列表 ({{ localMusicUrls.length }})
                            </h6>
                            <button 
                                v-if="localMusicUrls.length > 0" 
                                class="btn btn-sm btn-outline-danger"
                                @click="clearAllMusic"
                                :disabled="isProcessing"
                            >
                                <i class="fas fa-trash me-1"></i>清空
                            </button>
                        </div>

                        <div v-if="localMusicUrls.length === 0" class="empty-state">
                            <i class="fas fa-music fa-2x mb-2"></i>
                            <p class="mb-0">暂无音乐，请添加音乐URL</p>
                        </div>

                        <div v-else class="music-list">
                            <div 
                                v-for="(url, index) in localMusicUrls" 
                                :key="index"
                                class="music-item"
                                :class="{ 'editing': editingIndex === index }"
                            >
                                <!-- 编辑模式 -->
                                <div v-if="editingIndex === index" class="edit-mode">
                                    <div class="input-group">
                                        <input 
                                            type="url" 
                                            class="form-control" 
                                            v-model="editingMusicUrl" 
                                            @keyup.enter="saveEditedMusicUrl"
                                            @keyup.esc="cancelEdit"
                                            :disabled="isProcessing"
                                            ref="editInput"
                                        >
                                        <button 
                                            class="btn btn-success btn-sm" 
                                            @click="saveEditedMusicUrl"
                                            :disabled="!editingMusicUrl.trim() || isProcessing"
                                        >
                                            <i class="fas fa-check"></i>
                                        </button>
                                        <button 
                                            class="btn btn-secondary btn-sm" 
                                            @click="cancelEdit"
                                            :disabled="isProcessing"
                                        >
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                                
                                <!-- 显示模式 -->
                                <div v-else class="display-mode">
                                    <div class="music-url">
                                        <i class="fas fa-music text-primary me-2"></i>
                                        <span :title="url">{{ url }}</span>
                                    </div>
                                    <div class="music-actions">
                                        <button 
                                            class="btn btn-sm btn-outline-primary" 
                                            @click="editMusicUrl(index)"
                                            :disabled="isProcessing"
                                            title="编辑"
                                        >
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button 
                                            class="btn btn-sm btn-outline-danger" 
                                            @click="removeMusicUrl(index)"
                                            :disabled="isProcessing"
                                            title="删除"
                                        >
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- 模态框底部 -->
                <div class="custom-modal-footer">
                    <button 
                        type="button" 
                        class="btn btn-secondary" 
                        @click="closeModal"
                        :disabled="isProcessing"
                    >
                        <i class="fas fa-times me-1"></i>取消
                    </button>
                    <button 
                        type="button" 
                        class="btn btn-primary" 
                        @click="saveChanges"
                        :disabled="isProcessing"
                    >
                        <i class="fas fa-save me-1"></i>
                        {{ isProcessing ? '保存中...' : '保存更改' }}
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
/* eslint-disable no-undef */
import { ref, watch, defineProps, defineEmits, nextTick, onMounted, onUnmounted } from 'vue';

const props = defineProps({
    musicUrls: { type: Array, default: () => [] }
});

const emits = defineEmits(['save']);

// 响应式数据
const isVisible = ref(false);
const localMusicUrls = ref([]);
const newMusicUrl = ref('');
const editingIndex = ref(null);
const editingMusicUrl = ref('');
const isProcessing = ref(false);
const editInput = ref(null);

// 监听props变化，同步本地数据
watch(() => props.musicUrls, (newVal) => {
    localMusicUrls.value = [...newVal];
}, { immediate: true, deep: true });

// 验证URL格式
const isValidUrl = (string) => {
    try {
        new URL(string);
        return true;
    } catch (_) {
        return false;
    }
};

// 显示模态框
const showModal = () => {
    isVisible.value = true;
    localMusicUrls.value = [...props.musicUrls];
    cancelEdit();
    document.body.style.overflow = 'hidden'; // 防止背景滚动
};

// 关闭模态框
const closeModal = () => {
    if (isProcessing.value) return;
    
    isVisible.value = false;
    newMusicUrl.value = '';
    cancelEdit();
    document.body.style.overflow = ''; // 恢复滚动
};

// 添加音乐URL
const addMusicUrl = () => {
    const url = newMusicUrl.value.trim();
    if (!url) {
        alert('请输入音乐URL！');
        return;
    }
    
    if (!isValidUrl(url)) {
        alert('请输入有效的URL地址！');
        return;
    }
    
    if (localMusicUrls.value.includes(url)) {
        alert('该音乐URL已存在！');
        return;
    }
    
    isProcessing.value = true;
    setTimeout(() => {
        localMusicUrls.value.push(url);
        newMusicUrl.value = '';
        isProcessing.value = false;
    }, 300);
};

// 编辑音乐URL
const editMusicUrl = (index) => {
    if (editingIndex.value !== null) {
        cancelEdit();
    }
    editingIndex.value = index;
    editingMusicUrl.value = localMusicUrls.value[index];
    
    nextTick(() => {
        if (editInput.value && editInput.value[0]) {
            editInput.value[0].focus();
            editInput.value[0].select();
        }
    });
};

// 保存编辑的URL
const saveEditedMusicUrl = () => {
    const url = editingMusicUrl.value.trim();
    if (!url) {
        alert('请输入音乐URL！');
        return;
    }
    
    if (!isValidUrl(url)) {
        alert('请输入有效的URL地址！');
        return;
    }
    
    if (url !== localMusicUrls.value[editingIndex.value] && localMusicUrls.value.includes(url)) {
        alert('该音乐URL已存在！');
        return;
    }
    
    isProcessing.value = true;
    setTimeout(() => {
        localMusicUrls.value[editingIndex.value] = url;
        cancelEdit();
        isProcessing.value = false;
    }, 300);
};

// 取消编辑
const cancelEdit = () => {
    editingIndex.value = null;
    editingMusicUrl.value = '';
};

// 删除音乐URL
const removeMusicUrl = (index) => {
    if (confirm('确定要删除此音乐URL吗？')) {
        isProcessing.value = true;
        setTimeout(() => {
            localMusicUrls.value.splice(index, 1);
            if (editingIndex.value === index) {
                cancelEdit();
            } else if (editingIndex.value !== null && editingIndex.value > index) {
                editingIndex.value--;
            }
            isProcessing.value = false;
        }, 300);
    }
};

// 清空所有音乐
const clearAllMusic = () => {
    if (confirm('确定要清空所有音乐URL吗？')) {
        isProcessing.value = true;
        setTimeout(() => {
            localMusicUrls.value = [];
            cancelEdit();
            isProcessing.value = false;
        }, 300);
    }
};

// 保存更改
const saveChanges = () => {
    if (editingIndex.value !== null) {
        alert('请先完成当前编辑！');
        return;
    }
    
    isProcessing.value = true;
    setTimeout(() => {
        emits('save', [...localMusicUrls.value]);
        isProcessing.value = false;
        closeModal();
    }, 500);
};

// ESC键关闭模态框
const handleKeyDown = (event) => {
    if (event.key === 'Escape' && isVisible.value) {
        closeModal();
    }
};

// 暴露方法给父组件（Vue 3 Composition API）
defineExpose({
    showModal,
    closeModal
});

onMounted(() => {
    document.addEventListener('keydown', handleKeyDown);
});

onUnmounted(() => {
    document.removeEventListener('keydown', handleKeyDown);
    document.body.style.overflow = ''; // 确保恢复滚动
});
</script>

<style scoped>
.custom-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 2000;
    backdrop-filter: blur(2px);
}

.custom-modal-dialog {
    width: 90%;
    max-width: 600px;
    max-height: 90vh;
    display: flex;
    flex-direction: column;
}

.custom-modal-content {
    background: white;
    border-radius: 12px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    display: flex;
    flex-direction: column;
    max-height: 90vh;
    overflow: hidden;
}

.custom-modal-header {
    padding: 20px 24px;
    border-bottom: 1px solid #e5e5e5;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: linear-gradient(135deg, #007bff, #0056b3);
    color: white;
}

.custom-modal-title {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 600;
    flex: 1;
}

.custom-close-btn {
    background: none;
    border: none;
    color: white;
    font-size: 1.25rem;
    cursor: pointer;
    padding: 4px 8px;
    border-radius: 4px;
    transition: background-color 0.2s;
}

.custom-close-btn:hover {
    background-color: rgba(255, 255, 255, 0.2);
}

.custom-modal-body {
    padding: 24px;
    overflow-y: auto;
    flex: 1;
}

.custom-modal-footer {
    padding: 16px 24px;
    border-top: 1px solid #e5e5e5;
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    background-color: #f8f9fa;
}

.config-section {
    margin-bottom: 32px;
}

.config-section:last-child {
    margin-bottom: 0;
}

.section-title {
    color: #333;
    font-weight: 600;
    margin-bottom: 16px;
    font-size: 1rem;
}

.empty-state {
    text-align: center;
    padding: 32px;
    color: #6c757d;
}

.music-list {
    border: 1px solid #e5e5e5;
    border-radius: 8px;
    overflow: hidden;
}

.music-item {
    padding: 16px;
    border-bottom: 1px solid #e5e5e5;
    transition: background-color 0.2s;
}

.music-item:last-child {
    border-bottom: none;
}

.music-item:hover {
    background-color: #f8f9fa;
}

.music-item.editing {
    background-color: #fff3cd;
}

.display-mode {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
}

.music-url {
    flex: 1;
    display: flex;
    align-items: center;
    min-width: 0;
}

.music-url span {
    text-overflow: ellipsis;
    overflow: hidden;
    white-space: nowrap;
}

.music-actions {
    display: flex;
    gap: 8px;
}

.edit-mode {
    width: 100%;
}

.input-group .btn {
    border-radius: 0 6px 6px 0;
}

.input-group .btn:not(:last-child) {
    border-radius: 0;
    border-right: 1px solid #dee2e6;
}

.input-group .form-control {
    border-radius: 6px 0 0 6px;
}

/* 响应式设计 */
@media (max-width: 768px) {
    .custom-modal-dialog {
        width: 95%;
        margin: 20px;
    }
    
    .custom-modal-header {
        padding: 16px 20px;
    }
    
    .custom-modal-body {
        padding: 20px;
    }
    
    .custom-modal-footer {
        padding: 12px 20px;
        flex-direction: column;
    }
    
    .custom-modal-footer .btn {
        width: 100%;
    }
    
    .display-mode {
        flex-direction: column;
        align-items: stretch;
        gap: 12px;
    }
    
    .music-actions {
        justify-content: center;
    }
}

/* 确保不会影响页面其他元素 */
.custom-modal-overlay * {
    box-sizing: border-box;
}
</style>