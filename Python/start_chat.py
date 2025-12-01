# start_chat.py
import os
from google import genai

# --- 1. Client Setup (Pulls key from $env:GEMINI_API_KEY) ---
try:
    client = genai.Client()
    
    # Targeting the latest preview model
    MODEL_NAME = "gemini-3-pro-preview"  
    
    # --- 2. Start a New Chat Session ---
    # This creates a stateful conversation object with the new model.
    chat = client.chats.create(model=MODEL_NAME) 
    
    print(f"--- Chat with {MODEL_NAME} started. Type 'quit' or 'exit' to end. ---")
    
    # --- 3. Interactive Loop ---
    while True:
        user_prompt = input("You: ")
        if user_prompt.lower() in ['quit', 'exit']:
            break
        
        # Send the message and update the conversation history
        print("Gemini is thinking...")
        response = chat.send_message(user_prompt)
        
        # Print the model's response
        print(f"\nGemini: {response.text}\n")

except Exception as e:
    print(f"An error occurred: {e}. Check your API key and installation.")