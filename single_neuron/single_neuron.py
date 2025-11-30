import numpy as np
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Activation
from tensorflow.keras.optimizers import SGD

import hls4ml

# ---------- 1. Build a tiny Keras model ----------
model = Sequential()
model.add(Dense(1, input_shape=(2,), name='dense'))
model.add(Activation('relu', name='relu'))

model.compile(optimizer=SGD(0.1), loss='mse')

# some tiny dummy data just to make it non-random
X = np.array([
    [1.0, -0.5],
    [0.5,  0.2],
    [-1.0, 0.3],
    [2.0, -1.0],
], dtype=np.float32)
y = np.array([[1.0], [0.5], [0.0], [2.0]], dtype=np.float32)

model.fit(X, y, epochs=100, verbose=0)

# save Keras model (you already saw tiny_nn.h5)
model.save('tiny_nn.h5')
print("Saved Keras model to tiny_nn.h5")

# ---------- 2. Convert to hls4ml ----------
config = hls4ml.utils.config_from_keras_model(model, granularity='model')

# simple fixed-point type for everything
config['Model']['Precision'] = 'ap_fixed<16,6>'
config['Model']['ReuseFactor'] = 1

print("hls4ml config:", config)

hls_model = hls4ml.converters.convert_from_keras_model(
    model,
    hls_config=config,
    output_dir='tiny_hls_vivado',
    backend='Vivado'   # or 'Vivado' if you use Vivado HLS
)

# compile C model (checks it works)
hls_model.compile()

print("hls4ml project written to tiny_hls_vivado/")
