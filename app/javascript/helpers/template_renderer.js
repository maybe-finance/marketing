export default class TemplateRenderer {
  constructor(template) {
    this.template = template
  }
  
  render(data) {
    const clone = document.importNode(this.template.content, true)
    this.#processNodes(clone, data)
    return clone
  }
  
  #processNodes(root, data) {
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT, null, false);

    while (walker.nextNode()) {
      const node = walker.currentNode
      this.#processAttributes(node, data)
    }
  }
  
  #processAttributes(node, data) {
    const attributes = Array.from(node.attributes)

    for (const attr of attributes) {
      if (attr.name.startsWith('t-')) {
        const [type, prop] = attr.name.split(':')
        const value = this.#evaluateExpression(attr.value, data)
        this.#applyAttribute(node, type, prop, value)
        node.removeAttribute(attr.name)
      }
    }
  }

  #evaluateExpression(expression, data) {
    try {
      const func = new Function(...Object.keys(data), `return (${expression});`)
      return func(...Object.values(data))
    } catch (e) {
      console.error(`Error evaluating expression: ${expression}`, e)
      return null;
    }
  }
  
  #applyAttribute(node, type, prop, value) {
    switch (type) {
      case 't-text':
        node.textContent = value;
        break;
      case 't-attr':
        node.setAttribute(prop, value)
        break;
      case 't-if':
        if (!value) node.remove()
        break;
      default:
        break;
    }
  }
}
