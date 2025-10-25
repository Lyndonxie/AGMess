// 定义随机鼠标移动函数
function randomMouseMove() {
    const x = Math.random() * window.innerWidth; // 随机X坐标
    const y = Math.random() * window.innerHeight; // 随机Y坐标

    const event = new MouseEvent('mousemove', {
        clientX: x,
        clientY: y,
        bubbles: true,
        cancelable: true,
        view: window
    });

    document.dispatchEvent(event); // 触发鼠标移动事件
    console.log(`鼠标移动到: (${x.toFixed(2)}, ${y.toFixed(2)})`);
}

// 每30秒触发一次
setInterval(randomMouseMove, 15000);
