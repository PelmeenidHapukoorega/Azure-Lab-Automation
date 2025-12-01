# start_chat.py (FINAL, COMPATIBLE VERSION)
import os
from google import genai

try:
    client = genai.Client()
    
    # Using the fast, generally available model (best chance to avoid hangs)
    MODEL_NAME = "gemini-2.5-flash" 
    
    chat = client.chats.create(model=MODEL_NAME) 
    
    print(f"--- Chat with {MODEL_NAME} started. Type 'quit' or 'exit' to end. ---")
    
    while True:
        user_prompt = input("You: ")
        if user_prompt.lower() in ['quit', 'exit']:
            break
        
        print("Gemini is thinking...")
        
        # Removed 'timeout' argument to fix "unexpected keyword argument" error
        response = chat.send_message(user_prompt) 
        
        print(f"\nGemini: {response.text}\n")

except Exception as e:
    # This will now only catch network/connection errors if they persist
    print(f"An error occurred: {e}. Check your network connection.")