Core Pagination Loop
The main function iterates through the token array, calculating the accumulated height. When adding a token exceeds the column limit, it triggers the Kinsoku Shori resolution logic to determine how to break the column.

Python
function build_columns(tokens, config, max_column_height):
    columns = []
    current_column = []
    current_height = 0.0
    
    i = 0
    while i < tokens.length:
        token = tokens[i]
        token_height = calculate_node_height(token, config)
        
        if current_height + token_height > max_column_height:
            # The column is full. Resolve line breaking rules.
            resolution = resolve_kinsoku(current_column, token, config, current_height, max_column_height)
            
            if resolution.action == "burasagari":
                current_column.push(token)
                columns.push(current_column)
                current_column = []
                current_height = 0.0
                i += 1
                
            else if resolution.action == "oikomi":
                apply_spacing_compression(current_column, resolution.compression_amount)
                current_column.push(token)
                columns.push(current_column)
                current_column = []
                current_height = 0.0
                i += 1
                
            else if resolution.action == "oidashi":
                # Break normally before the current token
                columns.push(current_column)
                current_column = []
                current_height = 0.0
                # Do not increment i, evaluate token again on the new line
                
            else if resolution.action == "push_previous":
                # Pop tokens until the column ends with a valid character
                popped_tokens = []
                
                while current_column.length > 0:
                    popped = current_column.pop()
                    popped_tokens.insert_at_start(popped)
                    
                    if is_valid_line_end(current_column.last(), config):
                        break
                
                columns.push(current_column)
                
                # Start new column with the popped tokens
                current_column = popped_tokens
                current_height = calculate_total_height(current_column, config)
                # Do not increment i, evaluate token again after the popped tokens
                
        else:
            current_column.push(token)
            current_height += token_height
            i += 1

    if current_column.length > 0:
        columns.push(current_column)
        
    return columns
Kinsoku Resolution Logic
This function determines the typographic action required when a boundary is breached. It evaluates unsplittable sequences, forbidden line starts (Gyoto), and forbidden line ends (Gyomatsu).

Python
function resolve_kinsoku(current_column, next_token, config, current_height, max_column_height):
    last_token = current_column.last()
    
    # Check for Buntetsu Kinsoku (Unsplittable pairs like —— or …)
    if is_unsplittable_sequence(last_token, next_token):
        return { action: "push_previous" }

    # Check for Gyoto Kinsoku (Forbidden Start)
    if is_in_array(next_token.value, config.kinsoku.forbidden_start):
        
        # Priority 1: Burasagari (Hanging Punctuation)
        if config.kinsoku.mode == "burasagari" and is_hanging_punctuation(next_token):
            return { action: "burasagari" }
            
        # Priority 2: Oikomi (Compression)
        # Calculate how much space can be removed from punctuation spacing in the current line
        shrinkable_space = calculate_shrinkable_space(current_column)
        overflow_amount = (current_height + calculate_node_height(next_token, config)) - max_column_height
        
        if config.kinsoku.mode in ["oikomi", "burasagari"] and shrinkable_space >= overflow_amount:
            return { action: "oikomi", compression_amount: overflow_amount }
            
        # Priority 3: Oidashi (Push Out)
        # If we cannot hang or compress, the previous character must move to the next line 
        # to accompany the forbidden-start character.
        return { action: "push_previous" }

    # Check for Gyomatsu Kinsoku (Forbidden End)
    if is_in_array(last_token.value, config.kinsoku.forbidden_end):
        # Example: The line ends with an opening bracket "「". 
        # It cannot stay at the bottom of the column.
        return { action: "push_previous" }

    # Default fallback: Break normally before the next token
    return { action: "oidashi" }
Helper Algorithms
These logic blocks support the primary resolution engine by calculating available spacing and validating characters.

Python
function calculate_shrinkable_space(column_tokens):
    total_shrinkable = 0.0
    
    for i from 0 to column_tokens.length - 1:
        current = column_tokens[i]
        next_tok = column_tokens[i + 1] if i + 1 < column_tokens.length else null
        
        # Yakumono (punctuation) usually has 0.5em of compressible space (Aki)
        if is_compressible_punctuation(current):
            total_shrinkable += 0.5 * config.font_size
            
        # Consecutive punctuation can often be compressed further
        if next_tok != null and is_compressible_punctuation(current) and is_compressible_punctuation(next_tok):
            total_shrinkable += 0.25 * config.font_size
            
    return total_shrinkable


function apply_spacing_compression(column_tokens, amount_to_remove):
    remaining_to_remove = amount_to_remove
    
    # Distribute the compression across all yakumono in the line
    for token in column_tokens:
        if remaining_to_remove <= 0:
            break
            
        if is_compressible_punctuation(token):
            # Reduce the bounding box height of the token
            reduction = min(0.5 * config.font_size, remaining_to_remove)
            token.margin_bottom -= reduction
            remaining_to_remove -= reduction


function is_valid_line_end(token, config):
    if token == null:
        return false
    if is_in_array(token.value, config.kinsoku.forbidden_end):
        return false
    return true