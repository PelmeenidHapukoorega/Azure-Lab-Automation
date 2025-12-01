# start_chat.py (FINAL, RELIABLE VERSION)
import os
from google import genai

try:
    client = genai.Client()
    
    # Using the fast, generally available model
    MODEL_NAME = "gemini-2.5-flash" 
    
    chat = client.chats.create(model=MODEL_NAME) 
    
    print(f"--- Chat with {MODEL_NAME} started. Type 'quit' or 'exit' to end. ---")
    
    while True:
        user_prompt = input("You: ")
        if user_prompt.lower() in ['quit', 'exit']:
            break
        
        print("Gemini is thinking...")
        
        # Sending the message with a 60-second timeout to prevent freezing
        response = chat.send_message(user_prompt, timeout=60) 
        
        print(f"\nGemini: {response.text}\n")

except Exception as e:
    # This will now catch both API key and Timeout errors
    print(f"An error occurred: {e}. Check your API key, installation, and network connection.")