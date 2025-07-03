// 模态框测试脚本 - 在浏览器控制台中运行此脚本
function testModal() {
    console.log("=== 模态框测试开始 ===");
    
    // 1. 检查Bootstrap是否加载
    if (typeof window.bootstrap === 'undefined') {
        console.error("❌ Bootstrap未加载！");
        return;
    }
    console.log("✅ Bootstrap已加载");
    
    // 2. 检查模态框元素是否存在
    const modalElement = document.getElementById('musicConfigModal');
    if (!modalElement) {
        console.error("❌ 模态框元素不存在！");
        return;
    }
    console.log("✅ 模态框元素存在");
    
    // 3. 检查模态框的z-index
    const modalComputedStyle = window.getComputedStyle(modalElement);
    const backdrop = document.querySelector('.modal-backdrop');
    console.log(`📊 模态框z-index: ${modalComputedStyle.zIndex}`);
    if (backdrop) {
        const backdropStyle = window.getComputedStyle(backdrop);
        console.log(`📊 背景遮罩z-index: ${backdropStyle.zIndex}`);
    }
    
    // 4. 检查模态框实例
    const modalInstance = window.bootstrap.Modal.getInstance(modalElement);
    console.log(`📊 模态框实例: ${modalInstance ? '已创建' : '未创建'}`);
    
    // 5. 测试模态框显示
    try {
        const modal = modalInstance || new window.bootstrap.Modal(modalElement);
        modal.show();
        console.log("✅ 模态框显示成功");
        
        // 检查模态框是否可见
        setTimeout(() => {
            const isVisible = modalElement.classList.contains('show');
            console.log(`📊 模态框可见状态: ${isVisible ? '可见' : '不可见'}`);
            
            // 检查输入框是否可编辑
            const inputs = modalElement.querySelectorAll('input');
            const editableInputs = Array.from(inputs).filter(input => !input.disabled);
            console.log(`📊 可编辑输入框数量: ${editableInputs.length}/${inputs.length}`);
            
            // 检查按钮是否可点击
            const buttons = modalElement.querySelectorAll('button');
            const clickableButtons = Array.from(buttons).filter(btn => !btn.disabled);
            console.log(`📊 可点击按钮数量: ${clickableButtons.length}/${buttons.length}`);
            
            // 关闭模态框
            setTimeout(() => {
                modal.hide();
                console.log("✅ 模态框关闭测试完成");
                console.log("=== 模态框测试结束 ===");
            }, 2000);
        }, 1000);
        
    } catch (error) {
        console.error("❌ 模态框显示失败:", error);
    }
}

// 检查页面DOM是否准备好
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        console.log("页面加载完成，可以运行 testModal() 函数");
    });
} else {
    console.log("页面已准备好，可以运行 testModal() 函数");
}

// 导出函数到全局
window.testModal = testModal;

console.log(`
🔧 模态框诊断工具已加载
运行 testModal() 来测试模态框功能
`);