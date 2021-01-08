# This is a python comment in my first python app
"""This is a multiline comment also called a docstring
docstrings starts and ends with three double quotation marks"""
print("THe old pond\nA frog jumped in, \nKerplunk!")

num = 10
if num > 0:
    print("Positive number")
else:
    print("Negative number")

# This variable contains an integer
quantity = 10
# This variable contains a float
unit_price = 1.99
# This variable contains the result of multiplying
extended_price = quantity*unit_price
# Show the results
print(extended_price)
# number formatting
print(f"Subtotal: ${quantity*unit_price:,.2f}")
sales_tax_rate = 0.065
print(f"Sales Tax Rate {sales_tax_rate:.2%}")
print(f"Sales Tax Rate {sales_tax_rate:.1%}")

sample1 = f'Sales Tax Rate {sales_tax_rate:.2%}'
sample2 = f"Sales Tax Rate {sales_tax_rate:.2%}"
sample3 = f"""Sales Tax Rate {sales_tax_rate:.2%}"""
sample4 = f'''Sales Tax Rate {sales_tax_rate:.2%}'''

print(sample1)
print(sample2)
print(sample3)
print(sample4)
# if use triple """, don't need \n
sales_tax = sales_tax_rate * extended_price
total = extended_price + sales_tax
# '>9' -> make 9 characters wide and right aligned
# ',' -> separate with commas
# '.2f' -> 2 decimal places"""
output = f"""
Subtotal:   ${extended_price:>9,.2f}
Sales Tax:  ${sales_tax:>9,.2f}
Total:      ${total:>9,.2f}
"""
print(output)
# now move the dollar sign
# create strings with $ attached
s_subtotal = "$" + f"{extended_price:,.2f}"
s_sales_tax = "$" + f"{sales_tax:,.2f}"
s_total = "$" + f"{total:,.2f}"

output_s = f"""
Subtotal:   {s_subtotal:>9}
Sales Tax:  {s_sales_tax:>9}
Total:      {s_total:>9}
"""
print(output_s)

first_name = "Scarlett"; last_name = "Attensil"; print(first_name, last_name)

x = 10
if x == 0:
    print("x is zero")
else:
    print("x is  ", x)
print("All done")

username = "Scarlett"
print(f"Hello {username}")

# line breaks
user1 = "Alberto"
user2 = "Babs"
user3 = "Carlos"
output = f"{user1} \n{user2} \n{user3}"
print(output)

first_name = "Scarlett"
middle_init = "L"
last_name = "Attensil"
full_name = first_name + middle_init + last_name
print(full_name)
full_name = first_name + " "+ middle_init + ". "+ last_name
print(full_name)

