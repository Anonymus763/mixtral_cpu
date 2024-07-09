import uvicorn
from pydantic import BaseModel
from fastapi import FastAPI
from loguru import logger
from functools import lru_cache
from huggingface_hub import hf_hub_download
from llama_cpp import Llama
import time


class PromptModel(BaseModel):
    prompt: str


class MixtralResponse(BaseModel):
    text: str


app = FastAPI()

MODEL_PATH = "/app/mixtral_cpu/mixtral-8x7b-instruct-v0.1.Q3_K_M.gguf"
#MODEL_PATH = "demo/mixtral_cpu/mixtral-8x7b-instruct-v0.1.Q3_K_M.gguf"

@lru_cache(maxsize=1)
def get_mixtral_model():
    start_time = time.time()
    logger.info(f"Loading model from {MODEL_PATH}...")

    llm = Llama(
        model_path=MODEL_PATH,
        n_ctx=16000,  # Kontextlänge
        n_threads=32,  # Anzahl der CPU-Threads
        n_gpu_layers=0,  # Anzahl der Modellschichten, die auf die GPU ausgelagert werden
    )
    
    end_time = time.time()
    load_time = end_time - start_time
    logger.info(f"Model successfully loaded. Took {load_time:.0f} seconds")
    return llm


@app.post("/mixtral", response_model=MixtralResponse)
async def execute_prompt(prompt_model: PromptModel) -> MixtralResponse:
    try:
        logger.info(f"Prompt: {prompt_model.prompt}")
        llm = get_mixtral_model()

        generation_kwargs = {
            "max_tokens": 1300,
            "stop": ["</s>"],
            "echo": False,  # Echo the prompt in the output
            "top_k": 1,  # Greedy decoding
        }

        res = llm(prompt_model.prompt, **generation_kwargs)

        logger.info(f"res: {res}")
        return MixtralResponse(text=res["choices"][0]["text"])

    except Exception as e:
        logger.error(f"error: {str(e)}")
        return MixtralResponse(text=f"Error: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)