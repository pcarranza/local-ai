from docker.io/rocm/dev-ubuntu-24.04:7.2-complete

RUN apt update \
	&& apt-get -y install curl gawk grep sed unzip zstd \
		mesa-vulkan-drivers vulkan-tools libvulkan1 \
		rocminfo \
	&& apt-get -y clean

RUN curl -fsSL https://ollama.com/install.sh | bash

# Use experimental vulkan to access the GPU
ENV OLLAMA_VULKAN=1

# Set ollama debug output level
ENV OLLAMA_DEBUG=0

# Keep the model alive forever
ENV OLLAMA_KEEP_ALIVE=-1

# Which model to preload on startup
ENV PRELOAD_MODEL=qwen3.5:2b

# consider a quantized cache if low on memory
# ENV OLLAMA_KV_CACHE_TYPE=q8_0

# consider changing the context window if needed
# ENV OLLAMA_CONTEXT_LENGTH=8192

WORKDIR /workspace

CMD [ "/usr/local/bin/ollama", "serve" ]
