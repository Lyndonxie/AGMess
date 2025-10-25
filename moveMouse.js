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

    // 在移动后模拟一次左键点击（mousedown -> mouseup -> click）
    // 使用短延迟以更接近真实用户行为
    setTimeout(() => {
        const options = {
            clientX: x,
            clientY: y,
            bubbles: true,
            cancelable: true,
            view: window,
            button: 0 // 0 表示左键
        };

        const mdown = new MouseEvent('mousedown', options);
        document.dispatchEvent(mdown);

        const mup = new MouseEvent('mouseup', options);
        document.dispatchEvent(mup);

        const click = new MouseEvent('click', options);
        document.dispatchEvent(click);

        console.log(`模拟左键点击: (${x.toFixed(2)}, ${y.toFixed(2)})`);
    }, 50);
}

// 每10秒触发一次
setInterval(randomMouseMove, 10000);
